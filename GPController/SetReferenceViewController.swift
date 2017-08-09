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
    
    @IBOutlet var gridView: UIView!
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
    
    @IBOutlet weak var arrowPad: UIView!
    @IBOutlet weak var upButton: RoundAxisButton!
    @IBOutlet weak var rightButton: RoundAxisButton!
    @IBOutlet weak var downButton: RoundAxisButton!
    @IBOutlet weak var leftButton: RoundAxisButton!
    @IBOutlet weak var indicatorTriangle: TriangleView!

    @IBOutlet weak var setStartButton: FlexiButton!
    @IBOutlet weak var gridButton: FlexiButton!
    @IBOutlet weak var previewButton: FlexiButton!
    
    fileprivate var freeformIsEnabled: Bool = false
    fileprivate var displayedForm: UIView?
    
    var gpBTManager: GPBluetoothManager?
    var panoManager: PanoManager?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
            
            activeCornerButton?.backgroundColor = UIColor.sandpaperWhite
            activeCornerButton?.cacheBackgroundColor()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        arrowPad.isUserInteractionEnabled = false
        arrowPad.alpha = 0.7
        indicatorTriangle.alpha = 0
        indicatorTriangle.layer.removeAllAnimations()
        
        controlPanel.alpha = 1
        controlPanel.isUserInteractionEnabled = true
        displayedForm?.removeFromSuperview()

        gridButton.activate(false, animated: false)
        previewButton.activate(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func displayForm(_ sender: UIButton) {
        let form: UIView?
        
        switch sender.tag {
        case 0:
            freeformIsEnabled = true
            form = moveToStartView
        case 1:
            freeformIsEnabled = false
            
            if let manager = panoManager {
                referencePointLabel.text = "(\(manager.grid.x), \(manager.grid.y))"
            }

            form = gridView
        case 2:
            freeformIsEnabled = true
            form = previewView
        default:
            form = nil
        }
        
        guard let subview = form else {
            return
        }
        
        view.addSubview(subview)
        subview.bounds = displaySection.bounds
        subview.center = displaySection.center
        subview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        subview.alpha = 0
        displayedForm = subview
        
        controlPanel.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.4, animations: {
            subview.transform = .identity
            subview.alpha = 1
            self.controlPanel.alpha = 0
            self.arrowPad.alpha = 1.0
        }, completion: { _ in
            self.indicatorTriangle.layer.addFlashLayer()
            self.arrowPad.isUserInteractionEnabled = true
        })
    }
    
    @IBAction func dismissForm(_ sender: UIButton) {
        let form: UIView?
        
        switch sender.tag {
        case 0, 3:
            form = moveToStartView
        case 1:
            form = gridView
        case 2:
            form = previewView
        default:
            form = nil
        }
        
        guard let subview = form else {
            return
        }
        
        arrowPad.isUserInteractionEnabled = false
        indicatorTriangle.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.4, animations: {
            subview.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            subview.alpha = 0
            self.controlPanel.alpha = 1
            self.indicatorTriangle.alpha = 0
            self.arrowPad.alpha = 0.7
        }) { _ in
            self.controlPanel.isUserInteractionEnabled = true
            subview.removeFromSuperview()
            
            if (sender.tag == 3) {
                self.panoManager?.grid.moveToStart()
                self.gridButton.activate(true, animated: true)
                self.previewButton.activate(true, animated: true)
            }
        }
    }
    
    // MARK: - Movement Handlers
    
    @IBAction func moveToCorner(_ sender: FlexiButton) {
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

    @IBAction func moveToCenter(_ sender: FlexiButton) {
        activeCornerButton = sender
        
        panoManager?.moveToCenter()
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
    
    @IBAction func completeSetup(_ sender: UIButton) {
        performSegue(withIdentifier: "completeSetup", sender: self)
    }
    
    // MARK: - Navigation
    
    @IBAction func back(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "completeSetup") {
            if let dest = segue.destination as? PanoSessionViewController {
                dest.panoManager = self.panoManager
            }
        }
    }
}




