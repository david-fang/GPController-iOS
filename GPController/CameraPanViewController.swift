//
//  ViewController.swift
//  GPController
//
//  Created by David Fang on 5/25/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class CameraPanViewController: UIViewController {

    @IBOutlet weak var up: RoundAxisButton!
    @IBOutlet weak var right: RoundAxisButton!
    @IBOutlet weak var down: RoundAxisButton!
    @IBOutlet weak var left: RoundAxisButton!
    
    var motorManager: MotorManager!
    var buttonPulse: PulseLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        left.direction = .Left
        up.direction = .Up
        down.direction = .Down
        right.direction = .Right
        
        let dirButtons: [RoundAxisButton] = [left, up, down, right]
        for button in dirButtons {
            button.addTarget(self, action: #selector(self.beginMove), for: .touchDown)
            button.addTarget(self, action: #selector(self.stopMove), for: .touchDragOutside)
            button.addTarget(self, action: #selector(self.stopMove), for: .touchUpInside)
            button.addTarget(self, action: #selector(self.stopMove), for: .touchUpOutside)
        }

        motorManager = MotorManager(left: left, up: up, down: down, right: right)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beginMove(sender: RoundAxisButton) {
        buttonPulse = PulseLayer(radius: sender.frame.height * 0.8, position: sender.center)
        buttonPulse?.animationDuration = 1.5
        buttonPulse?.backgroundColor = sender.borderColor.cgColor

        if let buttonPulse = buttonPulse {
            self.view.layer.insertSublayer(buttonPulse, below: sender.layer)
        }

        motorManager.moveGigapan(sender: sender)
    }
    
    func stopMove() {
        buttonPulse?.removeFromSuperlayer()
        motorManager.stop()
    }

}

