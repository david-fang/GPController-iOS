/**
 * GPCommands.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * String arguments that are sent to the GigaPan for parsing
 * and executing commands. Command strings are usually of the
 * format <ACTION> <ARG (optional)>
 *
 */

import Foundation

class GPCommands {
    static let pause = "PAUSE"
    static let forward = "FORWARD"
    static let backward = "BACKWARD"
    static let left = "LEFT"
    static let right = "RIGHT"
    static let shutter = "SHUTTER"
}
