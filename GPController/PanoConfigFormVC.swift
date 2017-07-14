//
//  ProtoFormViewController.swift
//  GPController
//
//  Created by David Fang on 7/12/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class PanoConfigFormVC: UIViewController {

    @IBOutlet weak var identifierButton: UIButton!
    @IBOutlet weak var componentsStepper: GMStepper!
    @IBOutlet weak var fovStepper: GMStepper!
    @IBOutlet weak var overlapStepper: GMStepper!
    
    @IBOutlet weak var componentsToggle: UISwitch!
    @IBOutlet weak var fovToggle: UISwitch!
    @IBOutlet weak var overlapToggle: UISwitch!
    
    let hLensFOV: Double = 90
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        identifierButton.layer.cornerRadius = 4.0
        identifierButton.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func toggleSwitch(_switch: UISwitch, on: Bool) {
        _switch.setOn(on, animated: true)
        _switch.isEnabled = on
    }

    @IBAction func updateValues(sender: GMStepper) {
        if (componentsToggle.isOn && fovToggle.isOn) {
            overlapStepper.value = GPCalculate.overlap(numComponents: componentsStepper.value, panoFOV: fovStepper.value, lensFOV: hLensFOV)
        } else if (componentsToggle.isOn && overlapToggle.isOn) {
            fovStepper.value = GPCalculate.panoFOV(numComponents: componentsStepper.value, lensFOV: hLensFOV, overlap: overlapStepper.value)
        } else if (fovToggle.isOn && overlapToggle.isOn) {
            componentsStepper.value = GPCalculate.numComponents(panoFOV: fovStepper.value, lensFOV: hLensFOV, overlap: overlapStepper.value)
        }
    }
    
    @IBAction func updateSwitch(sender: UISwitch) {
        
        toggleSwitch(_switch: sender, on: false)
        
        // New value should be !sender.isOn
        // If turning off, find the one that is currently off
        // and is not sender, and turn it one
        
        if (!componentsToggle.isOn && sender != componentsToggle) {
            toggleSwitch(_switch: componentsToggle, on: true)
            componentsToggle.isEnabled = true
        } else if (!fovToggle.isOn && sender != fovToggle) {
            toggleSwitch(_switch: fovToggle, on: true)
        } else if (!overlapToggle.isOn && sender != overlapToggle) {
            toggleSwitch(_switch: overlapToggle, on: true)
        }
    }
    
}

