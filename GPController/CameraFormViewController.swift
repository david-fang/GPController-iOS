//
//  CameraFormViewController.swift
//  GPController
//
//  Created by David Fang on 7/18/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class CameraFormViewController: UIViewController {

    @IBOutlet weak var identifierButton: UIButton!
    @IBOutlet weak var hRESButton: UIButton!
    @IBOutlet weak var vRESButton: UIButton!
    @IBOutlet weak var hFOVStepper: GMStepper!
    @IBOutlet weak var vFOVStepper: GMStepper!

    var cameraConfigEditor: CameraConfigEditor!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initDefaultConfig()
        refreshMenuItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initDefaultConfig() {
        cameraConfigEditor = CameraConfigEditor()
    }
    
    func refreshMenuItems() {
        hFOVStepper.value = cameraConfigEditor.hFOV
        vFOVStepper.value = cameraConfigEditor.vFOV
        hRESButton.setTitle(String(cameraConfigEditor.hRES), for: .normal)
        vRESButton.setTitle(String(cameraConfigEditor.vRES), for: .normal)
    }
    
    @IBAction func updateHFOV(_ sender: GMStepper) {
        cameraConfigEditor.hFOV = hFOVStepper.value
    }
    
    @IBAction func updatevFOV(_ sender: GMStepper) {
        cameraConfigEditor.vFOV = vFOVStepper.value
    }
    
    @IBAction func saveCameraConfig(_ sender: UIButton) {
        if (cameraConfigEditor.hFOV == 0 || cameraConfigEditor.vFOV == 0) {
            let alert = UIAlertController(title: "Missing fields", message: "Camera configuration cannot have field of view of 0", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))

            self.present(alert, animated: true, completion: nil)
        }
        
        if cameraConfigEditor.identifier == nil {
            let alert = UIAlertController(title: "Missing fields", message: "Camera configuration cannot be saved without an identifier", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        else if (!cameraConfigEditor.saveCameraConfig()) {
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

    @IBAction func segueToSingleEdit(_ sender: UIButton) {
        performSegue(withIdentifier: "singleEditCamConfig", sender: sender)
    }

    @IBAction func unwindToCameraForm(segue: UIStoryboardSegue) {
        if let src = segue.source as? SingleValueEditViewController {

            if let val = src.updatedValue {
                if (src.updateTypeIdentifier == SingleValueEditViewController.camIDString) {
                    identifierButton.setTitle(val, for: .normal)
                    cameraConfigEditor.identifier = val
                } else if (src.updateTypeIdentifier == SingleValueEditViewController.lensHRESString) {
                    hRESButton.setTitle(val, for: .normal)
                    cameraConfigEditor.hRES = Int(val) ?? 0
                } else if (src.updateTypeIdentifier == SingleValueEditViewController.lensVRESString) {
                    vRESButton.setTitle(val, for: .normal)
                    cameraConfigEditor.vRES = Int(val) ?? 0
                }
            }
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "singleEditCamConfig") {
            if let dest = segue.destination as? SingleValueEditViewController {
                if let sender = sender as? UIButton {
                    switch (sender.tag) {
                    case 1:
                        dest.updateTypeIdentifier = SingleValueEditViewController.camIDString
                    case 2:
                        dest.updateTypeIdentifier = SingleValueEditViewController.lensHRESString
                    case 3:
                        dest.updateTypeIdentifier = SingleValueEditViewController.lensVRESString
                    default:
                        break
                    }
                }
            }
        }
    }
}



