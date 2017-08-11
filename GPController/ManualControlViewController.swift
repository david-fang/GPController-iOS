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
    @IBOutlet weak var triangleIndicator: TriangleView!
    
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
        triangleIndicator.layer.addFlashLayer()
    }
    
    @IBAction func triggerShutter(_ sender: FlexiButton) {
        gpBTManager.send(text: GPCommands.shutter)
    }
    
    func beginMove(sender: RoundAxisButton) {
        switch sender.direction {
        case .left:
            gpBTManager.send(text: GPCommands.left)
        case .up:
            gpBTManager.send(text: GPCommands.forward)
        case .down:
            gpBTManager.send(text: GPCommands.backward)
        case .right:
            gpBTManager.send(text: GPCommands.right)
        }
    }
    
    func stopMove() {
        gpBTManager.send(text: GPCommands.pause)
    }

    @IBAction func back(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

