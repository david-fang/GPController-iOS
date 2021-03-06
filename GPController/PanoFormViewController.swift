/**
 *
 * PanoramaFormViewController.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * Controller for creating, previewing, and editing
 * PanoramaConfigs. This controller enforces valid
 * config inputs before saving.
 *
 */

import UIKit

class PanoFormViewController: UIViewController {

    // MARK: - Subviews
    
    @IBOutlet weak var identifierButton: UIButton!

    @IBOutlet weak var componentsStepper: GMStepper!
    @IBOutlet weak var fovStepper: GMStepper!
    @IBOutlet weak var overlapStepper: GMStepper!

    @IBOutlet weak var componentsToggle: UISwitch!
    @IBOutlet weak var fovToggle: UISwitch!
    @IBOutlet weak var overlapToggle: UISwitch!

    @IBOutlet weak var componentsLabel: UILabel!
    @IBOutlet weak var fovLabel: UILabel!
    @IBOutlet weak var overlapLabel: UILabel!

    @IBOutlet weak var horizontalToggle: UIButton!
    @IBOutlet weak var verticalToggle: UIButton!

    // MARK: - Config Variables
    
    var panoConfigEditor: PanoConfigEditor!
    var activeAxis: Axis = .horizontal {
        didSet {
            refreshMenuItems()
        }
    }

    var camera: CameraConfig!
    var selectedPano: PanoConfig?

    // MARK: - Bluetooth Variables
    
    var gpBTManager: GPBluetoothManager?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If a panorama was selected, populate the form with its values.
        // Otherwise, create a new config with default values
        
        if let panoConfig = selectedPano {
            panoConfigEditor = PanoConfigEditor(config: panoConfig, camHFOV: Int(camera.hFOV), camVFOV: Int(camera.vFOV))
        } else {
            panoConfigEditor = PanoConfigEditor(camHFOV: Int(camera.hFOV), camVFOV: Int(camera.vFOV))
        }

        performFullRefresh()
        
        // Pull the bluetooth manager from the navigation controller
        
        if let nc = self.navigationController as? GPNavigationController {
            self.gpBTManager = nc.gpBTManager
        }
    }
    
    /**
     * Loads both the vertical axis and horizontal axis subviews
     * with the proper values. This step is crucial, as it makes
     * sure that 'unlocked' values from the config are computed during
     * the population of the form, preventing lots of mathematical
     * errors and outdated values.
     */
    fileprivate func performFullRefresh() {
        activeAxis = .vertical
        refreshMenuItems()
        activeAxis = .horizontal
        refreshMenuItems()
    }
    
    /**
     * Refreshes the form's values based on the currently active
     * axis (i.e. horizontal or vertical settings)
     */
    func refreshMenuItems() {
        if (activeAxis == .horizontal) {
            componentsLabel.text = "NUMBER OF COLUMNS"
            fovLabel.text = "HORIZONTAL PANO FOV"
            overlapLabel.text = "HORIZONTAL OVERLAP"
            fovStepper.maximumValue = 360
        } else {
            componentsLabel.text = "NUMBER OF ROWS"
            fovLabel.text = "VERTICAL PANO FOV"
            overlapLabel.text = "VERTICAL OVERLAP"
            fovStepper.maximumValue = 180
        }
        
        if let title = panoConfigEditor.getIdentifier() {
            identifierButton.setTitle(title, for: .normal)
        } else {
            identifierButton.setTitle("What should I name this?", for: .normal)
        }

        let valueSet = panoConfigEditor.getValueSet(for: activeAxis)
        let lockSet = panoConfigEditor.getLockSet(for: activeAxis)
        
        toggleSwitch(_switch: componentsToggle, on: lockSet.componentsLock)
        toggleSwitch(_switch: fovToggle, on: lockSet.fovLock)
        toggleSwitch(_switch: overlapToggle, on: lockSet.overlapLock)
        
        if (componentsToggle.isOn) { componentsStepper.value = valueSet.components }
        if (fovToggle.isOn)        { fovStepper.value = valueSet.fov }
        if (overlapToggle.isOn)    { overlapStepper.value = valueSet.overlap }
    }

    // MARK: - Settings Toggle Functions
    
    @IBAction func didSelectAxis(_ sender: UIButton) {
        activeAxis = (activeAxis == .horizontal) ? .vertical : .horizontal

        let inactiveButton: UIButton = (activeAxis == .horizontal) ? verticalToggle : horizontalToggle

        togglePlanarButton(_button: sender, on: true)
        togglePlanarButton(_button: inactiveButton, on: false)
    }

    // MARK: - Switch Update Functions
    
    @IBAction func unlockNumComponents(_ sender: UISwitch) {
        toggleSwitch(_switch: sender, on: false)
        panoConfigEditor.setComponentsLock(for: activeAxis, to: false)
        updateSwitch(sender: sender)
    }
    
    @IBAction func unlockPanoFOV(_ sender: UISwitch) {
        toggleSwitch(_switch: sender, on: false)
        panoConfigEditor.setFOVLock(for: activeAxis, to: false)
        updateSwitch(sender: sender)
    }
    
    @IBAction func unlockOverlap(_ sender: UISwitch) {
        toggleSwitch(_switch: sender, on: false)
        panoConfigEditor.setOverlapLock(for: activeAxis, to: false)
        updateSwitch(sender: sender)
    }
    
    fileprivate func updateSwitch(sender: UISwitch) {
        if (!componentsToggle.isOn && sender != componentsToggle) {
            toggleSwitch(_switch: componentsToggle, on: true)
            panoConfigEditor.setComponentsLock(for: activeAxis, to: true)
        }
        else if (!fovToggle.isOn && sender != fovToggle) {
            toggleSwitch(_switch: fovToggle, on: true)
            panoConfigEditor.setFOVLock(for: activeAxis, to: true)
            
        }
        else if (!overlapToggle.isOn && sender != overlapToggle) {
            toggleSwitch(_switch: overlapToggle, on: true)
            panoConfigEditor.setOverlapLock(for: activeAxis, to: true)
        }
    }
    
    // MARK: - Stepper Update Functions
    
    @IBAction func updateNumComponents(_ sender: GMStepper) {
        panoConfigEditor.setComponents(for: activeAxis, to: sender.value)
        updateAllStepperValues(for: activeAxis)
    }
    
    @IBAction func updatePanoFOV(_ sender: GMStepper) {
        panoConfigEditor.setFieldOfView(for: activeAxis, to: sender.value)
        updateAllStepperValues(for: activeAxis)
    }
    
    @IBAction func updateOverlap(_ sender: GMStepper) {
        panoConfigEditor.setOverlap(for: activeAxis, to: sender.value)
        updateAllStepperValues(for: activeAxis)
    }
    
    /** Computes the third, unlocked value based on the two locked values */
    fileprivate func updateAllStepperValues(for axis: Axis) {
        let cameraFOV: Int = axis == .horizontal ? Int(camera.hFOV) : Int(camera.vFOV)
        let valueSet = panoConfigEditor.getValueSet(for: axis)
        
        if (componentsToggle.isOn && fovToggle.isOn) {
            overlapStepper.value = GPCalculate.overlap(numComponents: valueSet.components, panoFOV: valueSet.fov, lensFOV: cameraFOV)
        } else if (componentsToggle.isOn && overlapToggle.isOn) {
            fovStepper.value = GPCalculate.panoFOV(numComponents: valueSet.components, lensFOV: cameraFOV, overlap: valueSet.overlap)
        } else if (fovToggle.isOn && overlapToggle.isOn) {
            componentsStepper.value = GPCalculate.numComponents(panoFOV: valueSet.fov, lensFOV: cameraFOV, overlap: valueSet.overlap)
        }
    }
    
    // MARK: - Display Toggle Functions
    
    fileprivate func toggleSwitch(_switch: UISwitch, on: Bool) {
        _switch.isEnabled = on
        _switch.setOn(on, animated: true)
        
        if (_switch == componentsToggle) {
            toggleStepper(_stepper: componentsStepper, on: on)
        } else if (_switch == fovToggle) {
            toggleStepper(_stepper: fovStepper, on: on)
        } else if (_switch == overlapToggle) {
            toggleStepper(_stepper: overlapStepper, on: on)
        }
    }
    
    fileprivate func toggleStepper(_stepper: GMStepper, on: Bool) {
        _stepper.isEnabled = on
        UIView.animate(withDuration: 0.2, animations: {
            _stepper.alpha = on ? 1.0 : 0.5
        }, completion: nil)
    }
    
    fileprivate func togglePlanarButton(_button: UIButton, on: Bool) {

        _button.isEnabled = !on
        UIView.animate(withDuration: 0.3, animations: {
            _button.alpha = on ? 1.0 : 0.5
            _button.titleLabel?.font = on ? UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20) : UIFont(name: "AppleSDGothicNeo-SemiBold", size: 17)
        }, completion: nil)
    }
    
    // MARK: - CoreData
    
    @IBAction func savePanoConfig(_sender: UIButton) {
        
        // Displays alert if the identifier is empty

        if panoConfigEditor.getIdentifier() == nil {
            let alert = UIAlertController(title: "Missing fields", message: "Panorama configuration cannot be saved without an identifier", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        // Displays alert if the identifier is not unique
            
        else if (!panoConfigEditor.savePanoConfig()) {
            let alert = UIAlertController(title: "Invalid identifier", message: "The desired identifier is already being used by an existing configuration", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func back(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segueToShootingConfig(_ sender: UIButton) {
        performSegue(withIdentifier: "toShootingConfig", sender: sender)
    }
    
    @IBAction func segueToSingleEdit(sender: UIButton) {
        performSegue(withIdentifier: "singleEditPanoConfig", sender: sender)
    }
    
    @IBAction func unwindToPanoForm(segue: UIStoryboardSegue) {
        if let src = segue.source as? SingleValueEditViewController {
            if (src.updateTypeIdentifier == SingleValueEditViewController.panoIDString) {
                if let val = src.updatedValue {
                    identifierButton.setTitle(val, for: .normal)
                    panoConfigEditor.setIdentifier(to: val)
                } else {
                    identifierButton.setTitle("What should I name this?", for: .normal)
                    _ = panoConfigEditor.setIdentifier(to: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "singleEditPanoConfig") {
            if let dest = segue.destination as? SingleValueEditViewController {
                dest.updateTypeIdentifier = SingleValueEditViewController.panoIDString
            }
        } else if (segue.identifier == "toShootingConfig") {
            if let dest = segue.destination as? ShootingConfigViewController {
                dest.hValueSet = panoConfigEditor.getValueSet(for: .horizontal)
                dest.vValueSet = panoConfigEditor.getValueSet(for: .vertical)
            }
        }
    }

}
