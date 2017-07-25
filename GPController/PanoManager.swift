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
}

enum Corner {
    case topLeft, topRight, bottomLeft, bottomRight
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
    
    let grid: PanoGrid
    var delegate: PanoramaListenerDelegate?

    var isCompleted: Bool {
        return curColumn == columns && curRow == rows && !pendingPicture
    }

    required init(with manager: GPBluetoothManager, columns: Int, rows: Int, vAngle: Int, hAngle: Int) {
        self.manager = manager
        self.columns = columns
        self.rows = rows
        self.vAngle = vAngle
        self.hAngle = hAngle
        self.grid = PanoGrid(rows: rows, columns: columns, startPosition: .topLeft)
    }
    
    /** Performs any final setup and starts the panorama session */
    func start() {
        manager.listener = self
        pendingPicture = true
        next()
    }
    
    /**
     * Performs the next action on the queue. By default, the current
     * movement pattern is a snake pattern. 
     */
    fileprivate func next() {
        if !isCompleted {
            if (pendingPicture) {
                pendingPicture = false
                manager.send(text: GP_SHUTTER)
                return
            }

            if (curColumn == columns) {
                move(dir: .up, angle: vAngle)
                curRow = curRow + 1
                curColumn = 1
            } else {
                let dir: Direction = curRow % 2 == 0 ? .left : .right
                move(dir: dir, angle: hAngle)
                curColumn = curColumn + 1
            }
            
            pendingPicture = true
            
        } else {
            delegate?.panoramaDidFinish()
            print("DONE")
        }
    }
    
    /**
     * Creates a command string message for panoramas with some fixed
     * amount of panning.
     *
     * - parameter dir: the direction of rotation
     * - parameter angle: the angle at which to rotate each iteration by
     */
    fileprivate func move(dir: Direction, angle: Int) {
        var cmd: String

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
    
    func tiltForward() {
        if (grid.move(dir: .up)) {
            move(dir: .up, angle: vAngle)
        }
    }
    
    func tiltBackward() {
        if (grid.move(dir: .down)) {
            move(dir: .down, angle: vAngle)
        }
    }
    
    func panLeft() {
        if (grid.move(dir: .left)) {
            move(dir: .left, angle: hAngle)
        }
    }
    
    func panRight() {
        if (grid.move(dir: .right)) {
            move(dir: .right, angle: hAngle)
        }
    }
    
    func moveToCorner(corner: Corner) {
        
        var numPans = 0
        var numTilts = 0
        
        let panHandler: () -> Void
        let tiltHandler: () -> Void

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

        panHandler = numPans > 0 ? panRight : panLeft
        tiltHandler = numTilts > 0 ? tiltForward : tiltBackward

        for _ in 0..<abs(numPans) {
            panHandler()
        }

        for _ in 0..<abs(numTilts) {
            tiltHandler()
        }
    }

    func getColumn() -> Int {
        return curColumn
    }
    
    func getRow() -> Int {
        return curRow
    }
    
    func didReceiveCompletionCallback(msg: String) {
        if (msg == "OK") {
            next()
        }
    }
}
