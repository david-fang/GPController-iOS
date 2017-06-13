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
    
    var gpBTManager: GPBluetoothManager!
    var buttonPulse: PulseLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        left.direction = .left
        up.direction = .up
        down.direction = .down
        right.direction = .right
        
        let dirButtons: [RoundAxisButton] = [left, up, down, right]
        for button in dirButtons {
            button.addTarget(self, action: #selector(self.beginMove), for: .touchDown)
            button.addTarget(self, action: #selector(self.stopMove), for: .touchDragOutside)
            button.addTarget(self, action: #selector(self.stopMove), for: .touchUpInside)
            button.addTarget(self, action: #selector(self.stopMove), for: .touchUpOutside)
        }
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

        switch sender.direction {
        case .left:
            gpBTManager.send(text: "3")
            break
        case .up:
            gpBTManager.send(text: "1")
            break
        case .down:
            gpBTManager.send(text: "2")
            break
        case .right:
            gpBTManager.send(text: "4")
            break
        }
        
        // motorManager.moveGigapan(sender: sender)
    }
    
    func stopMove() {
        buttonPulse?.removeFromSuperlayer()
        gpBTManager.send(text: "0")
    }

}

