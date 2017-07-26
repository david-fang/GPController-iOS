//
//  PanoManager.swift
//  GPController
//
//  Created by David Fang on 6/30/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation

protocol PanoramaListenerDelegate {
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
}

enum Order {
    case rows, columns
}

enum Pattern {
    case unidirectional, snake
}

class PanoManager: NSObject, GPCallbackListenerDelegate {
    
    fileprivate let manager: GPBluetoothManager
    fileprivate let columns: Int
    fileprivate let rows: Int
    fileprivate let vAngle: Int
    fileprivate let hAngle: Int
    
    fileprivate var curColumn: Int = 1
    fileprivate var curRow: Int = 1
    fileprivate var pendingPicture: Bool = false
    
    fileprivate var primaryDirection: Direction
    fileprivate var secondaryDirection: Direction
    
    fileprivate var isRunning: Bool = false
    
    let grid: PanoGrid
    var delegate: PanoramaListenerDelegate?

    var isCompleted: Bool {
        return !grid.canMove(dir: primaryDirection) &&
               !grid.canMove(dir: secondaryDirection) &&
               !pendingPicture
    }

    required init(with manager: GPBluetoothManager, columns: Int, rows: Int, vAngle: Int, hAngle: Int, start: Corner, order: Order, pattern: Pattern) {
        self.manager = manager
        self.columns = columns
        self.rows = rows
        self.vAngle = vAngle
        self.hAngle = hAngle
        self.grid = PanoGrid(rows: rows, columns: columns, startPosition: .topLeft)

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
        isRunning = true
        next()
    }
    
    /**
     * Performs the next action on the queue. By default, the current
     * movement pattern is a snake pattern. 
     */
    fileprivate func next() {

        if (!isRunning) { return }
        
        if (isCompleted) {
            isRunning = false
            delegate?.panoramaDidFinish()
            print("Panorama completed")
            return
        }

        if (pendingPicture) {
            pendingPicture = false
            manager.send(text: GP_SHUTTER)
        } else {
            snakeNext()
            pendingPicture = true
        }
    }
    
    fileprivate func unidirectionalNext() {
        if (grid.canMove(dir: primaryDirection)) {
            takeSingleStep(dir: primaryDirection)
        } else {
            let angle = primaryDirection.movesAlongHorizontal ? hAngle : vAngle
            let numComponents = primaryDirection.movesAlongHorizontal ? columns : rows

            move(dir: primaryDirection.inverse, angle: numComponents * angle)
        }
    }
    
    fileprivate func snakeNext() {
        if (grid.canMove(dir: primaryDirection)) {
            takeSingleStep(dir: primaryDirection)
        } else {
            primaryDirection = primaryDirection.inverse
            takeSingleStep(dir: secondaryDirection)
        }
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

        manager.send(text: "\(cmd) \(angle)")
    }
    
    func takeSingleStep(dir: Direction) {
        if (grid.canMove(dir: dir)) {
            let angle = dir.movesAlongHorizontal ? hAngle : vAngle
            grid.move(dir: dir)
            self.move(dir: dir, angle: angle)
        }
    }

    func moveToCorner(corner: Corner) {
        var numPans = 0
        var numTilts = 0
        let horizontalDir: Direction
        let verticalDir: Direction

        switch corner {
        case .topLeft:
            numPans = grid.x * -1
            numTilts = rows - grid.y - 1
        case .topRight:
            numPans = columns - grid.x - 1
            numTilts = rows - grid.y - 1
        case .bottomLeft:
            numPans = grid.x * -1
            numTilts = grid.y * -1
        case .bottomRight:
            numPans = columns - grid.x - 1
            numTilts = grid.y * -1
        }
        
        horizontalDir = numPans > 0 ? .right : .left
        verticalDir = numTilts > 0 ? .up : .down
        
        numPans = abs(numPans)
        numTilts = abs(numTilts)
        
        for i in 0..<numPans {
            if (!grid.canMove(dir: horizontalDir)) {
                fatalError("Grid cannot pan past bounds: \(i + 1)/\(numPans)")
            } else {
                grid.move(dir: horizontalDir)
            }
        }
        
        for i in 0..<numTilts {
            if (!grid.canMove(dir: verticalDir)) {
                fatalError("Grid cannot tilt past bounds: \(i + 1)/\(numTilts)")
            } else {
                grid.move(dir: verticalDir)
            }
        }
        
        self.move(dir: horizontalDir, angle: numPans * hAngle)
        self.move(dir: verticalDir, angle: numTilts * vAngle)
    }

    func getColumn() -> Int {
        return curColumn
    }
    
    func getRow() -> Int {
        return curRow
    }
    
    func didReceiveCompletionCallback(msg: String) {
        if (msg == "OK" && isRunning) {
            next()
        }
    }
}
