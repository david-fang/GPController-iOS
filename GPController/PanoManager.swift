//
//  PanoManager.swift
//  GPController
//
//  Created by David Fang on 6/30/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation

class PanoManager: NSObject, GPCallbackListenerDelegate {
    
    fileprivate let manager: GPBluetoothManager
    fileprivate let columns: Int
    fileprivate let rows: Int
    fileprivate let vAngle: Int
    fileprivate let hAngle: Int

    fileprivate var curColumn: Int = 1
    fileprivate var curRow: Int = 1
    fileprivate var pendingPicture: Bool = false

    var isCompleted: Bool {
        return curColumn == columns && curRow == rows && !pendingPicture
    }

    required init(with manager: GPBluetoothManager, columns: Int, rows: Int, vAngle: Int, hAngle: Int) {
        self.manager = manager
        self.columns = columns
        self.rows = rows
        self.vAngle = vAngle
        self.hAngle = hAngle
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

            var cmd: String
            if (curColumn == columns) {
                cmd = createCommandString(dir: .up, angle: vAngle)
                curRow = curRow + 1
                curColumn = 1
            } else {
                let dir: Direction = curRow % 2 == 0 ? .left : .right
                cmd = createCommandString(dir: dir, angle: hAngle)
                curColumn = curColumn + 1
            }

            pendingPicture = true
            manager.send(text: cmd)
        } else {
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
    fileprivate func createCommandString(dir: Direction, angle: Int) -> String {
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
        
        return "\(cmd) \(angle)"
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
