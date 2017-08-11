/**
 * GPEnums.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * Assorted enumerations used within the application. More
 * detailed documentation continued below.
 *
 */

import Foundation

/** Represents the horizontal and vertical axes. */

enum Axis {
    case horizontal
    case vertical
}

/** Represents directions of movement on a standard arrow-pad. */

enum Direction {
    case left, right, up, down
    
    /** Returns the inverse direction of the current direction. */
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
    
    /**
     * Returns true if the given direction moves along the
     * horizontal plane.
     */
    var movesAlongHorizontal: Bool {
        return (self == .left || self == .right)
    }
}

/** Represents the four corners of a panorama. */

enum Corner {
    case topLeft, topRight, bottomLeft, bottomRight
    
    /**
     * Returns true if the corner is one of the top corners
     * and false otherwise.
     */
    func isAlignedToTop() -> Bool {
        return (self == .topLeft || self == .topRight)
    }
    
    /**
     * Returns true if the corner is one of the left corners
     * and false otherwise.
     */
    func isAlignedToLeft() -> Bool {
        return (self == .topLeft || self == .bottomLeft)
    }
    
    /** The string representation of the Corner. */
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

/**
 * Represents the order of capturing either by rows (with
 * panning as the primary action) or by columns (with tilting
 * as the primary action).
 */

enum Order {
    case rows, columns
    
    /** The string representation of the Order. */
    var asString: String {
        switch self {
        case .rows:
            return "Rows"
        case .columns:
            return "Columns"
        }
    }
}

/** Represents the shooting pattern of a panorama. */
enum Pattern {
    case unidirectional, snake
    
    /** The string representation of the Pattern. */
    var asString: String {
        switch self {
        case .unidirectional:
            return "Unidirectional"
        case .snake:
            return "Snake"
        }
    }
}
