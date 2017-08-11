/**
 *
 * ManualControlViewController.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * Controller for the manual pan and tilt view. Reads user input
 * via the arrowpad and sends the respective command to the
 * GigaPan via a Bluetooth connection.
 *
 */

import UIKit

class ManualControlViewController: UIViewController {

    // MARK: - Subviews
    
    @IBOutlet weak var up: RoundAxisButton!
    @IBOutlet weak var right: RoundAxisButton!
    @IBOutlet weak var down: RoundAxisButton!
    @IBOutlet weak var left: RoundAxisButton!
    @IBOutlet weak var triangleIndicator: TriangleView!
    
    // MARK: - Bluetooth Variables
    
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

    // MARK: - GPCommand Management
    
    /**
     * Sends the appropriate command string based on the
     * button pressed. By nature, in freeform mode, the GigaPan
     * will not stop moving until it receives a stop command.
     * Freeform mode is achieved when no argument is paired with
     * the command. To do a fixed pan/tilt, take a look at the
     * PanoManager model.
     *
     * - Parameter sender: a RoundAxisButton, each representing one
     *      of the four directions
     */
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
    
    /** Effectively stops the GigaPan from moving in freeform mode. */
    func stopMove() {
        gpBTManager.send(text: GPCommands.pause)
    }

    /** Requests for the GigaPan to trigger the camera shutter. */
    @IBAction func triggerShutter(_ sender: FlexiButton) {
        gpBTManager.send(text: GPCommands.shutter)
    }
    
    // MARK: - Navigation
    
    @IBAction func back(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

