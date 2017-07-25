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
    
    func move(dir: Direction) -> Bool {
        switch dir {
        case .left:
            if (x <= 0) { return false }
            _x -= 1
        case .up:
            if (y >= rows - 1) { return false }
            _y += 1
        case .right:
            if (x >= columns - 1) { return false }
            _x += 1
        case .down:
            if (y <= 0) { return false }
            _y -= 1
        }
        
        return true
    }
}

