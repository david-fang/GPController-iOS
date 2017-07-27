//
//  SetReferenceViewController.swift
//  GPController
//
//  Created by David Fang on 7/24/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class SetReferenceViewController: UIViewController {
    
    @IBOutlet weak var displaySection: UIView!
    @IBOutlet weak var controlPanel: UIView!
    
    // MARK: - Start Position View
    
    @IBOutlet var moveToStartView: UIView!
    @IBOutlet weak var startViewLabel: UILabel!
    
    // MARK: - Edit Reference View
    
    @IBOutlet var editReferenceView: UIView!
    @IBOutlet weak var referencePointLabel: UILabel!

    // MARK: - Preview View
    
    @IBOutlet var previewView: UIView!
    @IBOutlet weak var topLeftButton: FlexiButton!
    @IBOutlet weak var topRightButton: FlexiButton!
    @IBOutlet weak var centerButton: FlexiButton!
    @IBOutlet weak var bottomLeftButton: FlexiButton!
    @IBOutlet weak var bottomRightButton: FlexiButton!
    
    var activeCornerButton: FlexiButton?
    
    // MARK: - Main View

    @IBOutlet weak var upButton: RoundAxisButton!
    @IBOutlet weak var rightButton: RoundAxisButton!
    @IBOutlet weak var downButton: RoundAxisButton!
    @IBOutlet weak var leftButton: RoundAxisButton!

    fileprivate var freeformIsEnabled: Bool = false
    
    var gpBTManager: GPBluetoothManager?
    var panoManager: PanoManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        upButton.direction = .up
        rightButton.direction = .right
        downButton.direction = .down
        leftButton.direction = .left
        
        let dirButtons: [RoundAxisButton] = [leftButton, upButton, downButton, rightButton]
        for button in dirButtons {
            button.addTarget(self, action: #selector(self.startMove), for: .touchDown)
            button.addTarget(self, action: #selector(self.stopMove), for: .touchDragOutside)
            button.addTarget(self, action: #selector(self.stopMove), for: .touchUpInside)
            button.addTarget(self, action: #selector(self.stopMove), for: .touchUpOutside)
        }
        
        if let manager = panoManager {
            referencePointLabel.text = "(\(manager.grid.x), \(manager.grid.y))"
            
            // Set up StartView layers

            startViewLabel.text = "Move GigaPan to the \(manager.startPosition.asString.lowercased()) position of the panorama"
            
            // Set up PreviewView layers
            
            switch manager.startPosition {
            case .topLeft:
                activeCornerButton = topLeftButton
            case .topRight:
                activeCornerButton = topRightButton
            case .bottomLeft:
                activeCornerButton = bottomLeftButton
            case .bottomRight:
                activeCornerButton = bottomRightButton
            }
            
            activeCornerButton?.activate(true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func displayEditForm(_ sender: UIButton) {
        view.addSubview(editReferenceView)
        editReferenceView.bounds = displaySection.bounds
        editReferenceView.center = displaySection.center
        
        controlPanel.alpha = 0
        controlPanel.isUserInteractionEnabled = false
    }
    
    @IBAction func displayInitForm(_ sender: UIButton) {
        freeformIsEnabled = true
        view.addSubview(moveToStartView)
        moveToStartView.bounds = displaySection.bounds
        moveToStartView.center = displaySection.center
        
        controlPanel.alpha = 0
        controlPanel.isUserInteractionEnabled = false
    }
    
    @IBAction func displayPreviewForm(_ sender: UIButton) {
        freeformIsEnabled = true
        view.addSubview(previewView)
        previewView.bounds = displaySection.bounds
        previewView.center = displaySection.center
        
        controlPanel.alpha = 0
        controlPanel.isUserInteractionEnabled = false
    }
    
    @IBAction func dismissInitForm(_ sender: UIButton) {
        freeformIsEnabled = false
        moveToStartView.removeFromSuperview()
        controlPanel.alpha = 1
        controlPanel.isUserInteractionEnabled = true
    }
    
    @IBAction func dismissPreviewForm(_ sender: UIButton) {
        freeformIsEnabled = false
        previewView.removeFromSuperview()
        controlPanel.alpha = 1
        controlPanel.isUserInteractionEnabled = true
    }
    
    @IBAction func dismissEditForm(_ sender: UIButton) {
        editReferenceView.removeFromSuperview()
        controlPanel.alpha = 1
        controlPanel.isUserInteractionEnabled = true
    }
    
    @IBAction func moveToCorner(_ sender: FlexiButton) {
        
        sender.activate(true)
        activeCornerButton?.activate(false)
        activeCornerButton = sender
        
        switch sender.tag {
        case 0:
            panoManager?.moveToCorner(corner: .topLeft)
        case 1:
            panoManager?.moveToCorner(corner: .topRight)
        case 2:
            panoManager?.moveToCorner(corner: .bottomLeft)
        case 3:
            panoManager?.moveToCorner(corner: .bottomRight)
        default:
            break;
        }
    }

    func startMove(_ sender: RoundAxisButton) {
        if (freeformIsEnabled) {
            freeformMove(sender)
        } else {
            fixedMove(sender)
        }
    }
    
    func freeformMove(_ sender: RoundAxisButton) {
        if let manager = gpBTManager {
            switch sender.direction {
            case .left:
                manager.send(text: GP_LEFT)
            case .up:
                manager.send(text: GP_FORWARD)
            case .down:
                manager.send(text: GP_BACKWARD)
            case .right:
                manager.send(text: GP_RIGHT)
            }
        }
    }
    
    func fixedMove(_ sender: RoundAxisButton) {
        if let manager = panoManager {
            manager.takeSingleStep(dir: sender.direction)
            referencePointLabel.text = "(\(manager.grid.x), \(manager.grid.y))"
        }
    }
    
    func stopMove(_ sender: RoundAxisButton) {
        sender.cancelTracking(with: nil)

        if (freeformIsEnabled) {
            if let manager = gpBTManager {
                manager.send(text: GP_PAUSE)
            }
        }
    }
    
    @IBAction func startPano(_ sender: UIButton) {
        panoManager?.start()
    }
    
    // MARK: - Navigation
    
    @IBAction func back(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}



