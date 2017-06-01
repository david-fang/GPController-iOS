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
    
    private var timer: Timer
    
    // Have it init with a bluetooth manager
    init(left: RoundAxisButton, up: RoundAxisButton, down: RoundAxisButton, right: RoundAxisButton) {
        self.timer = Timer()
    }

    func moveGigapan(sender: RoundAxisButton) {
        switch sender.direction {
            case .Left:
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                    self.moveLeft()
                })
                break
            case .Up:
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                    self.moveUp()
                })
                break
            case .Down:
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                    self.moveDown()
                })
                break
            case .Right:
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
    
    private func moveLeft() {
        print("Moving left...")
    }
    
    private func moveUp() {
        print("Moving up...")
    }
    
    private func moveDown() {
        print("Moving down...")
    }
    
    private func moveRight() {
        print("Moving right...")
    }
}
