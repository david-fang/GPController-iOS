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
    
    @IBAction func triggerShutter(_ sender: Any) {
        gpBTManager.send(text: GP_SHUTTER)
    }
    
    func beginMove(sender: RoundAxisButton) {
        buttonPulse = PulseLayer(radius: sender.frame.height * 1.0, position: sender.center)
        buttonPulse?.animationDuration = 1.5
        buttonPulse?.backgroundColor = sender.borderColor.cgColor

        if let buttonPulse = buttonPulse {
            self.view.layer.insertSublayer(buttonPulse, below: sender.layer)
        }

        switch sender.direction {
        case .left:
            gpBTManager.send(text: GP_LEFT)
            break
        case .up:
            gpBTManager.send(text: GP_FORWARD)
            break
        case .down:
            gpBTManager.send(text: GP_BACKWARD)
            break
        case .right:
            gpBTManager.send(text: GP_RIGHT)
            break
        }
    }
    
    func stopMove() {
        buttonPulse?.removeFromSuperlayer()
        gpBTManager.send(text: GP_PAUSE)
    }
    
    /* FOR DEMO */
    
    // Used for creating command strings with a fixed pan
    func createCommandString(dir: Direction, angle: Int) -> String {
        var cmd: String!
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
    
    /**
     * Panorama demo that closely resembles how the actual automation
     * will look like
     *
     * @arg numColumns: the number of columns this panorama has
     * @arg numRows: the number of rows this panorama has
     * @arg angle: the angle to rotate by at each iteration
     */
    func demoPanorama(numColumns: Int, numRows: Int, angle: Int) {
        var curDir: Direction = .right
        var cmd: String!
        for _ in 0..<numRows {
            for _ in 0..<numColumns {
                gpBTManager.send(text: GP_SHUTTER)
                cmd = createCommandString(dir: curDir, angle: angle)
                gpBTManager.send(text: cmd)
            }

            cmd = createCommandString(dir: .up, angle: angle)
            gpBTManager.send(text: cmd)
            
            if (curDir == .right) {
                curDir = .left
            } else {
                curDir = .right
            }
        }
    }
}

