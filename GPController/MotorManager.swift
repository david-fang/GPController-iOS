//
//  MotorManager.swift
//  GPController
//
//  Created by David Fang on 5/25/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation
import UIKit

class MotorManager {
    
    fileprivate var timer: Timer
    
    // Have it init with a bluetooth manager
    init(left: RoundAxisButton, up: RoundAxisButton, down: RoundAxisButton, right: RoundAxisButton) {
        self.timer = Timer()
    }

    func moveGigapan(_ sender: RoundAxisButton) {
        switch sender.direction {
            case .left:
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                    self.moveLeft()
                })
                break
            case .up:
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                    self.moveUp()
                })
                break
            case .down:
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                    self.moveDown()
                })
                break
            case .right:
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                    self.moveRight()
                })
                break
        }

        timer.fire()
    }
    
    func stop() {
        print("Stopping")
        timer.invalidate()
    }
    
    fileprivate func moveLeft() {
        print("Moving left...")
    }
    
    fileprivate func moveUp() {
        print("Moving up...")
    }
    
    fileprivate func moveDown() {
        print("Moving down...")
    }
    
    fileprivate func moveRight() {
        print("Moving right...")
    }
}
