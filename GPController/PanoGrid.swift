//
//  PanoGrid.swift
//  GPController
//
//  Created by David Fang on 7/25/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation

class PanoGrid {
    fileprivate let rows: Int
    fileprivate let columns: Int
    
    fileprivate var _x: Int
    fileprivate var _y: Int
    
    var x: Int {
        return _x
    }
    
    var y: Int {
        return _y
    }
    
    init(rows: Int, columns: Int, startPosition: Corner) {
        self.rows = rows
        self.columns = columns
        
        switch startPosition {
        case .topLeft:
            _x = 0; _y = rows - 1
        case .topRight:
            _x = columns - 1; _y = rows - 1
        case .bottomLeft:
            _x = 0; _y = 0
        case .bottomRight:
            _x = columns - 1; _y = 0
        }
    }
    
    func move(dir: Direction) {
        if (canMove(dir: dir)) {
            switch dir {
            case .left:
                _x -= 1
            case .up:
                _y += 1
            case .right:
                _x += 1
            case .down:
                _y -= 1
            }
        }
    }
    
    func canMove(dir: Direction) -> Bool {
        switch dir {
        case .left:
            return (x > 0)
        case .up:
            return (y < rows - 1)
        case .right:
            return (x < columns - 1)
        case .down:
            return (y > 0)
        }
    }
}

