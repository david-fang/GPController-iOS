//
//  PanoManager.swift
//  GPController
//
//  Created by David Fang on 6/30/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation

protocol PanoramaListenerDelegate {
    func nextCycleWillBegin(cycleNum: Int)
    func panoramaDidFinish()
}

class PanoManager: NSObject, GPCallbackListenerDelegate {
    
    enum PanoState {
        case stopped, paused, running, ready
    }
    
    fileprivate let manager: GPBluetoothManager
    fileprivate let tiltAngle: Int
    fileprivate let panAngle: Int

    fileprivate let order: Order
    fileprivate let pattern: Pattern
    fileprivate var primaryDirection: Direction
    fileprivate var secondaryDirection: Direction
    
    fileprivate var panoState: PanoState = .stopped
    fileprivate var pendingPicture: Bool = false
    
    fileprivate var pendingUnidirectionalSecondary: Bool = false
    fileprivate var commandCount: Int = 0
    
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
        self.order = order
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
        
        super.init()

        self.manager.listener = self
    }

    /** Performs any final setup and starts the panorama session */
    func start() {
        pendingPicture = true
        panoState = .ready
        moveToCorner(corner: grid.startPosition)
        delegate?.nextCycleWillBegin(cycleNum: getCycleNum())
    }
    
    func resumeAt(at x: Int, _ y: Int) {
        if (panoState == .paused) {
            if (grid.coordinateIsWithinBounds(for: x, y)) {
                pendingPicture = true
                panoState = .ready
                moveTo(x: x, y: y)
                delegate?.nextCycleWillBegin(cycleNum: getCycleNum())
            }
        }
    }
    
    func pause() {
        panoState = .paused
    }

    /**
     * Performs the next action on the queue. By default, the current
     * movement pattern is a snake pattern. 
     */
    @objc fileprivate func next() {
        if (panoState != .running) { return }
        
        if (isCompleted) {
            panoState = .stopped
            delegate?.panoramaDidFinish()
            return
        }

        if (pendingPicture) {
            delay(preTriggerDelay, closure: { self.triggerShutter() })
        } else {
            pattern == .snake ? snakeNext() : unidirectionalNext()
        }
    }

    @objc fileprivate func triggerShutter() {
        if (panoState != .running) { return }
        
        commandCount += 1
        manager.send(text: "\(GPCommands.shutter) \(self.bulb)")
        pendingPicture = false
    }
    
    fileprivate func unidirectionalNext() {
        if (panoState != .running) { return }
        
        if (pendingUnidirectionalSecondary) {
            takeSingleStep(dir: secondaryDirection)
            delegate?.nextCycleWillBegin(cycleNum: getCycleNum())
            pendingUnidirectionalSecondary = false
        } else if (grid.canMove(dir: primaryDirection)) {
            takeSingleStep(dir: primaryDirection)
            delegate?.nextCycleWillBegin(cycleNum: getCycleNum())
        } else {
            let angle = primaryDirection.movesAlongHorizontal ? panAngle : tiltAngle
            let numComponents = primaryDirection.movesAlongHorizontal ? grid.columns : grid.rows

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
        
        let mainDirection: Direction
        switch order {
        case .rows:
            mainDirection = startPosition.isAlignedToLeft() ? .right : .left
            primaryDirection = (abs(grid.y - grid.startY) % 2 == 0) ? mainDirection : mainDirection.inverse

        case .columns:
            mainDirection = startPosition.isAlignedToTop() ? .down : .up
            primaryDirection = (abs(grid.x - grid.startX) % 2 == 0) ? mainDirection : mainDirection.inverse
        }

        if (grid.canMove(dir: primaryDirection)) {
            takeSingleStep(dir: primaryDirection)
        } else {
            primaryDirection = primaryDirection.inverse
            takeSingleStep(dir: secondaryDirection)
        }

        delegate?.nextCycleWillBegin(cycleNum: getCycleNum())
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
            cmd = GPCommands.forward
        case .down:
            cmd = GPCommands.backward
        case .left:
            cmd = GPCommands.left
        case .right:
            cmd = GPCommands.right
        }

        commandCount += 1
        manager.send(text: "\(cmd) \(abs(angle))")
    }
    
    fileprivate func moveTo(x: Int, y: Int) {
        guard grid.coordinateIsWithinBounds(for: x, y) else {
            return
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
        
        moveTo(x: x, y: y)
    }
    
    // Moves to a point in the grid as close to the actual center as
    // possible.
    func moveToCenter() {
        let midX = (grid.columns - 1) / 2
        let midY = (grid.rows - 1) / 2
        
        moveTo(x: midX, y: midY)
    }
    
    func getPanoState() -> PanoState {
        return panoState
    }
    
    func getCycleNum() -> Int {
        switch pattern {
        case .unidirectional:
            switch order {
            case .rows:
                return abs(grid.y - grid.startY) * grid.columns + abs(grid.x - grid.startX) + 1
            case .columns:
                return abs(grid.x - grid.startX) * grid.rows + abs(grid.y - grid.startY) + 1
            }
        case .snake:
            switch order {
            case .rows:
                let remainder: Int
                if (startPosition.isAlignedToLeft()) {
                    remainder = (abs(grid.y - grid.startY) % 2 == 0) ? (grid.x + 1) : (grid.columns - grid.x)
                } else {
                    remainder = (abs(grid.y - grid.startY) % 2 == 0) ? (grid.columns - grid.x) : (grid.x + 1)
                }

                return abs(grid.y - grid.startY) * grid.columns + remainder

            case .columns:
                let remainder: Int
                if (startPosition.isAlignedToTop()) {
                    remainder = (abs(grid.x - grid.startX) % 2 == 0) ? (grid.rows - grid.y) : (grid.y + 1)
                } else {
                    remainder = (abs(grid.x - grid.startX) % 2 == 0) ? (grid.y + 1) : (grid.rows - grid.y)
                }

                return abs(grid.x - grid.startX) * grid.rows + remainder
            }
        }
    }

    func getStartPosition() -> Corner {
        return self.startPosition
    }
    
    // MARK: - Delegate Functions
    
    func didReceiveCompletionCallback(msg: String) {
        commandCount -= 1
        if panoState == .running {
            if (msg == "SHUTTER OK") {
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
