//
//  PanoManager.swift
//  GPController
//
//  Created by David Fang on 6/30/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation

protocol PanoramaListenerDelegate {
    func nextCycleWillBegin()
    func panoramaDidFinish()
}

enum Direction {
    case left, right, up, down
    
    var inverse: Direction {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        case .up:
            return .down
        case .down:
            return .up
        }
    }
    
    var movesAlongHorizontal: Bool {
        return (self == Direction.left || self == Direction.right)
    }
}

enum Corner {
    case topLeft, topRight, bottomLeft, bottomRight
    
    func isAlignedToTop() -> Bool {
        return (self == .topLeft || self == .topRight)
    }
    
    func isAlignedToLeft() -> Bool {
        return (self == .topLeft || self == .bottomLeft)
    }
    
    var asString: String {
        switch self {
        case .topLeft:
            return "Top left"
        case .topRight:
            return "Top right"
        case .bottomLeft:
            return "Bottom left"
        case .bottomRight:
            return "Bottom right"
        }
    }
}

enum Order {
    case rows, columns
    
    var asString: String {
        switch self {
        case .rows:
            return "Rows"
        case .columns:
            return "Columns"
        }
    }
}

enum Pattern {
    case unidirectional, snake
    
    var asString: String {
        switch self {
        case .unidirectional:
            return "Unidirectional"
        case .snake:
            return "Snake"
        }
    }
}

class PanoManager: NSObject, GPCallbackListenerDelegate {
    
    enum PanoState {
        case stopped, paused, running, ready
    }
    
    fileprivate let manager: GPBluetoothManager
    fileprivate let tiltAngle: Int
    fileprivate let panAngle: Int

    fileprivate let pattern: Pattern
    fileprivate var primaryDirection: Direction
    fileprivate var secondaryDirection: Direction
    
    fileprivate var panoState: PanoState = .stopped
    fileprivate var pendingPicture: Bool = false
    
    fileprivate var pendingUnidirectionalSecondary: Bool = false
    fileprivate var commandCount: Int = 0     // the number of commands sent
    
    fileprivate var cycleNum: Int = 0 {
        didSet {
            delegate?.nextCycleWillBegin()
        }
    }
    
    let startPosition: Corner
    let grid: PanoGrid
    var delegate: PanoramaListenerDelegate?

    var timer: Timer = Timer()
    var preTriggerDelay: Double = 0
    var bulb: Double = 0
    var postTriggerDelay: Double = 0
    
    var canReceiveNewCommand: Bool {
        return commandCount == 0
    }
    
    var isCompleted: Bool {
        return !grid.canMove(dir: primaryDirection) &&
               !grid.canMove(dir: secondaryDirection) &&
               !pendingPicture
    }

    required init(with manager: GPBluetoothManager, columns: Int, rows: Int, tiltAngle: Int, panAngle: Int, start: Corner, order: Order, pattern: Pattern) {
        self.manager = manager
        self.tiltAngle = tiltAngle
        self.panAngle = panAngle
        self.startPosition = start
        self.pattern = pattern
        self.grid = PanoGrid(rows: rows, columns: columns, startPosition: start)
        
        switch order {
        case .columns:
            primaryDirection = (start.isAlignedToTop()) ? .down : .up
            secondaryDirection = (start.isAlignedToLeft()) ? .right : .left
        case .rows:
            primaryDirection = (start.isAlignedToLeft()) ? .right : .left
            secondaryDirection = (start.isAlignedToTop()) ? .down : .up
        }
    }
    
    /** Performs any final setup and starts the panorama session */
    func start() {
        manager.listener = self
        pendingPicture = true
        panoState = .ready
        cycleNum = 1
        moveToCorner(corner: grid.startPosition)
    }
    
    func resume() {
        panoState = .running
        next()
    }
    
    func pause() {
        panoState = .paused
    }
    
    /**
     * Performs the next action on the queue. By default, the current
     * movement pattern is a snake pattern. 
     */
    @objc fileprivate func next() {
        print("Proceeding to next: \(Date())")
        
        if (panoState != .running) { return }
        
        if (isCompleted) {
            panoState = .stopped
            delegate?.panoramaDidFinish()
            return
        }

        if (pendingPicture) {
            print("Waiting for pre-trigger delay: \(Date())")
            delay(preTriggerDelay, closure: { self.triggerShutter() })
        } else {
            pattern == .snake ? snakeNext() : unidirectionalNext()
        }
    }

    @objc fileprivate func triggerShutter() {
        if (panoState != .running) { return }
        
        print("Picture fired: \(Date())")
        commandCount += 1
        manager.send(text: "\(GP_SHUTTER) \(self.bulb)")
        pendingPicture = false
    }
    
    fileprivate func unidirectionalNext() {
        if (panoState != .running) { return }
        
        if (pendingUnidirectionalSecondary) {
            takeSingleStep(dir: secondaryDirection)
            pendingUnidirectionalSecondary = false
        } else if (grid.canMove(dir: primaryDirection)) {
            cycleNum += 1
            takeSingleStep(dir: primaryDirection)
        } else {
            let angle = primaryDirection.movesAlongHorizontal ? panAngle : tiltAngle
            let numComponents = primaryDirection.movesAlongHorizontal ? grid.columns : grid.rows

            cycleNum += 1
            
            for _ in 0..<numComponents-1 {
                grid.move(dir: primaryDirection.inverse)
            }
            
            move(dir: primaryDirection.inverse, angle: (numComponents - 1) * angle)
            pendingUnidirectionalSecondary = true
            return
        }
            
        pendingPicture = true
    }
    
    fileprivate func snakeNext() {
        if (panoState != .running) { return }
        
        cycleNum += 1
        if (grid.canMove(dir: primaryDirection)) {
            takeSingleStep(dir: primaryDirection)
        } else {
            primaryDirection = primaryDirection.inverse
            takeSingleStep(dir: secondaryDirection)
        }
        
        pendingPicture = true
    }
    
    /**
     * Creates a command string message for panoramas with some fixed
     * amount of panning.
     *
     * - parameter dir: the direction of rotation
     * - parameter angle: the angle at which to rotate each iteration by
     */
    fileprivate func move(dir _dir: Direction, angle: Int) {
        var cmd: String
        var dir = _dir

        if (angle < 0) {
            dir = dir.inverse
        }

        switch dir {
        case .up:
            cmd = GP_FORWARD
        case .down:
            cmd = GP_BACKWARD
        case .left:
            cmd = GP_LEFT
        case .right:
            cmd = GP_RIGHT
        }

        commandCount += 1
        manager.send(text: "\(cmd) \(angle)")
    }
    
    fileprivate func moveTo(x: Int, y: Int) -> Bool {
        guard (x > -1 && x < grid.columns) else {
            return false
        }
        
        guard (y > -1 && y < grid.rows) else {
            return false
        }
        
        let horizontalDir: Direction
        let verticalDir: Direction
        var numPans = x - grid.x
        var numTilts = y - grid.y
        
        horizontalDir = numPans > 0 ? .right : .left
        verticalDir = numTilts > 0 ? .up : .down
        numPans = abs(numPans)
        numTilts = abs(numTilts)
        
        for i in 0..<numPans {
            guard (grid.canMove(dir: horizontalDir)) else {
                fatalError("Grid cannot pan past bounds: \(i + 1)/\(numPans)")
            }
            
            grid.move(dir: horizontalDir)
        }
        
        for i in 0..<numTilts {
            guard (grid.canMove(dir: verticalDir)) else {
                fatalError("Grid cannot tilt past bounds: \(i + 1)/\(numTilts)")
            }
            
            grid.move(dir: verticalDir)
        }

        self.move(dir: horizontalDir, angle: numPans * panAngle)
        self.move(dir: verticalDir, angle: numTilts * tiltAngle)
        
        return true
    }
    
    fileprivate func resumeAt(x: Int, y: Int) {
        if (panoState == .paused) {
            if (moveTo(x: x, y: y)) {
                panoState = .ready
            }
        }
    }
    
    func takeSingleStep(dir: Direction) {
        if (grid.canMove(dir: dir)) {
            let angle = dir.movesAlongHorizontal ? panAngle : tiltAngle
            grid.move(dir: dir)
            self.move(dir: dir, angle: angle)
        }
    }

    func moveToCorner(corner: Corner) {
        let x: Int
        let y: Int
        
        switch corner {
        case .topLeft:
            x = 0
            y = grid.rows - 1
        case .topRight:
            x = grid.columns - 1
            y = grid.rows - 1
        case .bottomLeft:
            x = 0
            y = 0
        case .bottomRight:
            x = grid.columns - 1
            y = 0
        }
        
        _ = moveTo(x: x, y: y)
    }
    
    func moveToCenter() {
        
    }
    
    func getPanoState() -> PanoState {
        return panoState
    }
    
    func getCycleNum() -> Int {
        return cycleNum
    }

    func getStartPosition() -> Corner {
        return self.startPosition
    }
    
    // MARK: - Delegate Functions
    
    func didReceiveCompletionCallback(msg: String) {
        commandCount -= 1
        print("Command count: \(commandCount)")
        if panoState == .running {
            if (msg == "SHUTTER OK") {
                print("Waiting for post-trigger delay: \(Date())")
                delay(postTriggerDelay, closure: { self.next() })
            } else if (msg == "MOTORS OK") {
                next()
            }
        } else if canReceiveNewCommand && panoState == .ready {
            panoState = .running
            next()
        }
    }
}
