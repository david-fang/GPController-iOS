//
//  ViewController.swift
//  GPController
//
//  Created by David Fang on 5/25/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class ManualControlViewController: UIViewController {

    @IBOutlet weak var up: RoundAxisButton!
    @IBOutlet weak var right: RoundAxisButton!
    @IBOutlet weak var down: RoundAxisButton!
    @IBOutlet weak var left: RoundAxisButton!
    
    var gpBTManager: GPBluetoothManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func triggerShutter(_ sender: FlexiButton) {
        gpBTManager.send(text: GP_SHUTTER)
    }
    
    func beginMove(sender: RoundAxisButton) {
        switch sender.direction {
        case .left:
            gpBTManager.send(text: GP_LEFT)
        case .up:
            gpBTManager.send(text: GP_FORWARD)
        case .down:
            gpBTManager.send(text: GP_BACKWARD)
        case .right:
            gpBTManager.send(text: GP_RIGHT)
        }
    }
    
    func stopMove() {
        gpBTManager.send(text: GP_PAUSE)
    }

    @IBAction func back(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

