//
//  ProtoFormViewController.swift
//  GPController
//
//  Created by David Fang on 7/12/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

fileprivate struct PanoConfiguration {
    var identifier:     String
    var rows:           Int
    var columns:        Int
    var hFOV:           Int
    var vFOV:           Int
    var hOverlap:       Int
    var vOverlap:       Int

    var rowsLock:       Bool
    var columnsLock:    Bool
    var hFOVLock:       Bool
    var vFOVLock:       Bool
    var hOverlapLock:   Bool
    var vOverlapLock:   Bool
}

class PanoConfigFormVC: UIViewController {
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

    fileprivate var configSet: PanoConfiguration!

    fileprivate var isShowingHorizontal: Bool = true
    
    let hLensFOV: Int = 90
    let vLensFOV: Int = 30
    
    var gpBTManager: GPBluetoothManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDefaultConfig()
        setupInitialStates()
        
        if let nc = self.navigationController as? GPNavigationController {
            self.gpBTManager = nc.gpBTManager
        }
    }

    @IBAction func startPano(_ sender: Any) {
        if let manager = gpBTManager {
            
            let verticalAngle = GPCalculate.angle(panoFOV: configSet.vFOV, numComponents: configSet.columns)
            let horizontalAngle = GPCalculate.angle(panoFOV: configSet.hFOV, numComponents: configSet.rows)
            
            let panoManager = PanoManager(with: manager, columns: configSet.columns, rows: configSet.rows, vAngle: verticalAngle, hAngle: horizontalAngle)
            panoManager.start()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupInitialStates() {
        toggleSwitch(_switch: componentsToggle, on: configSet.rowsLock)
        toggleSwitch(_switch: fovToggle, on: configSet.hFOVLock)
        toggleSwitch(_switch: overlapToggle, on: configSet.hOverlapLock)
        
        toggleStepper(_stepper: componentsStepper, on: configSet.rowsLock)
        toggleStepper(_stepper: fovStepper, on: configSet.hFOVLock)
        toggleStepper(_stepper: overlapStepper, on: configSet.hOverlapLock)
        
        componentsStepper.value = configSet.rows
        fovStepper.value = configSet.hFOV
        overlapStepper.value = configSet.hOverlap
    }
    
    func initDefaultConfig() {
        let numRows = GPCalculate.numComponents(panoFOV: DEFAULT_PANO_HFOV, lensFOV: hLensFOV, overlap: DEFAULT_PANO_OVERLAP)
        let numColumns = GPCalculate.numComponents(panoFOV: DEFAULT_PANO_VFOV, lensFOV: vLensFOV, overlap: DEFAULT_PANO_OVERLAP)
        
        configSet = PanoConfiguration(
            identifier: "",
            rows: numRows,
            columns: numColumns,
            hFOV: DEFAULT_PANO_HFOV,
            vFOV: DEFAULT_PANO_VFOV,
            hOverlap: DEFAULT_PANO_OVERLAP,
            vOverlap: DEFAULT_PANO_OVERLAP,
            rowsLock: true,
            columnsLock: true,
            hFOVLock: true,
            vFOVLock: true,
            hOverlapLock: false,
            vOverlapLock: false)
    }
    
    // MARK: - Settings Toggle Functions
    
    @IBAction func didSelectAxis(_ sender: UIButton) {
        isShowingHorizontal = !isShowingHorizontal

        let inactiveButton: UIButton
        if isShowingHorizontal {
            inactiveButton = verticalToggle
        } else {
            inactiveButton = horizontalToggle
        }

        togglePlanarButton(_button: sender, on: true)
        togglePlanarButton(_button: inactiveButton, on: false)

        updateSettingsMenu()
    }
    
    fileprivate func updateSettingsMenu() {
        if (isShowingHorizontal) {
            componentsLabel.text = "NUMBER OF ROWS"
            fovLabel.text = "HORIZONTAL PANO FOV"
            overlapLabel.text = "HORIZONTAL OVERLAP"
            
            toggleSwitch(_switch: componentsToggle, on: configSet.rowsLock)
            toggleSwitch(_switch: fovToggle, on: configSet.hFOVLock)
            toggleSwitch(_switch: overlapToggle, on: configSet.hOverlapLock)
            
            toggleStepper(_stepper: componentsStepper, on: configSet.rowsLock)
            toggleStepper(_stepper: fovStepper, on: configSet.hFOVLock)
            toggleStepper(_stepper: overlapStepper, on: configSet.hOverlapLock)

            componentsStepper.value = configSet.rows
            fovStepper.value = configSet.hFOV
            overlapStepper.value = configSet.hOverlap
        } else {
            componentsLabel.text = "NUMBER OF COLUMNS"
            fovLabel.text = "VERTICAL PANO FOV"
            overlapLabel.text = "VERTICAL OVERLAP"
            
            toggleSwitch(_switch: componentsToggle, on: configSet.columnsLock)
            toggleSwitch(_switch: fovToggle, on: configSet.vFOVLock)
            toggleSwitch(_switch: overlapToggle, on: configSet.vOverlapLock)
            
            toggleStepper(_stepper: componentsStepper, on: configSet.columnsLock)
            toggleStepper(_stepper: fovStepper, on: configSet.vFOVLock)
            toggleStepper(_stepper: overlapStepper, on: configSet.vOverlapLock)

            componentsStepper.value = configSet.columns
            fovStepper.value = configSet.vFOV
            overlapStepper.value = configSet.vOverlap
        }
    }

    // MARK: - Switch Update Functions
    
    @IBAction func unlockNumComponents(_ sender: UISwitch) {
        toggleSwitch(_switch: sender, on: false)
        toggleStepper(_stepper: componentsStepper, on: false)
        
        if (isShowingHorizontal) {
            configSet.rowsLock = false
        } else {
            configSet.columnsLock = false
        }
        
        updateSwitch(sender: sender)
    }
    
    @IBAction func unlockPanoFOV(_ sender: UISwitch) {
        toggleSwitch(_switch: sender, on: false)
        toggleStepper(_stepper: fovStepper, on: false)

        if (isShowingHorizontal) {
            configSet.hFOVLock = false
        } else {
            configSet.vFOVLock = false
        }
        
        updateSwitch(sender: sender)
    }
    
    @IBAction func unlockOverlap(_ sender: UISwitch) {
        toggleSwitch(_switch: sender, on: false)
        toggleStepper(_stepper: overlapStepper, on: false)
        
        if (isShowingHorizontal) {
            configSet.hOverlapLock = false
        } else {
            configSet.vOverlapLock = false
        }
        
        updateSwitch(sender: sender)
    }
    
    fileprivate func updateSwitch(sender: UISwitch) {
        if (!componentsToggle.isOn && sender != componentsToggle) {
            toggleSwitch(_switch: componentsToggle, on: true)
            toggleStepper(_stepper: componentsStepper, on: true)
            
            if (isShowingHorizontal) {
                configSet.rowsLock = true
            } else {
                configSet.columnsLock = true
            }
            
        } else if (!fovToggle.isOn && sender != fovToggle) {
            toggleSwitch(_switch: fovToggle, on: true)
            toggleStepper(_stepper: fovStepper, on: true)
            
            if (isShowingHorizontal) {
                configSet.hFOVLock = true
            } else {
                configSet.vFOVLock = true
            }
            
        } else if (!overlapToggle.isOn && sender != overlapToggle) {
            toggleSwitch(_switch: overlapToggle, on: true)
            toggleStepper(_stepper: overlapStepper, on: true)
            
            if (isShowingHorizontal) {
                configSet.hOverlapLock = true
            } else {
                configSet.vOverlapLock = true
            }
        }
    }
    
    // MARK: - Stepper Update Functions
    
    @IBAction func updateNumComponents(_ sender: GMStepper) {
        if (isShowingHorizontal) {
            configSet.rows = sender.value
        } else {
            configSet.columns = sender.value
        }
        
        updateAllStepperValues()
    }
    
    @IBAction func updatePanoFOV(_ sender: GMStepper) {
        if (isShowingHorizontal) {
            configSet.hFOV = sender.value
        } else {
            configSet.vFOV = sender.value
        }
        
        updateAllStepperValues()
    }
    
    @IBAction func updateOverlap(_ sender: GMStepper) {
        if (isShowingHorizontal) {
            configSet.hOverlap = sender.value
        } else {
            configSet.vOverlap = sender.value
        }
        
        updateAllStepperValues()
    }
    
    fileprivate func updateAllStepperValues() {
        let cameraFOV: Int
        if (isShowingHorizontal) {
            cameraFOV = hLensFOV
        } else {
            cameraFOV = vLensFOV
        }
        
        if (componentsToggle.isOn && fovToggle.isOn) {
            overlapStepper.value = GPCalculate.overlap(numComponents: componentsStepper.value, panoFOV: fovStepper.value, lensFOV: cameraFOV)
        } else if (componentsToggle.isOn && overlapToggle.isOn) {
            fovStepper.value = GPCalculate.panoFOV(numComponents: componentsStepper.value, lensFOV: cameraFOV, overlap: overlapStepper.value)
        } else if (fovToggle.isOn && overlapToggle.isOn) {
            componentsStepper.value = GPCalculate.numComponents(panoFOV: fovStepper.value, lensFOV: cameraFOV, overlap: overlapStepper.value)
        }
    }
    
    // MARK: - Display Toggle Functions
    
    fileprivate func toggleSwitch(_switch: UISwitch, on: Bool) {
        _switch.isEnabled = on
        _switch.setOn(on, animated: true)
    }
    
    fileprivate func toggleStepper(_stepper: GMStepper, on: Bool) {
        _stepper.isEnabled = on
        UIView.animate(withDuration: 0.3, animations: {
            _stepper.alpha = on ? 1.0 : 0.5
        }, completion: nil)
    }
    
    fileprivate func togglePlanarButton(_button: UIButton, on: Bool) {
        let titleColor = on ? UIColor(red: 209/255, green: 181/255, blue: 121/255, alpha: 1.0) : UIColor.white
        
        _button.isEnabled = !on
        UIView.animate(withDuration: 0.3, animations: {
            _button.alpha = on ? 1.0 : 0.5
            _button.setTitleColor(titleColor, for: .normal)
        }, completion: nil)
    }

    
}
