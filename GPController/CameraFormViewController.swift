//
//  CameraFormViewController.swift
//  GPController
//
//  Created by David Fang on 7/18/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class CameraFormViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var identifierButton: UIButton!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var hRESButton: UIButton!
    @IBOutlet weak var vRESButton: UIButton!
    @IBOutlet weak var hFOVStepper: GMStepper!
    @IBOutlet weak var vFOVStepper: GMStepper!

    var cameraConfigEditor: CameraConfigEditor!
    var imagePicker = UIImagePickerController()
    
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
        hRESButton.setTitle(String(cameraConfigEditor.hRES) + " px", for: .normal)
        vRESButton.setTitle(String(cameraConfigEditor.vRES) + " px", for: .normal)
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
            return
        }
        
        if cameraConfigEditor.identifier == nil {
            let alert = UIAlertController(title: "Missing fields", message: "Camera configuration cannot be saved without an identifier", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        else if (!cameraConfigEditor.saveCameraConfig()) {
            let alert = UIAlertController(title: "Invalid identifier", message: "The desired identifier is already being used by an existing configuration", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Image source", message: "Choose a source to get your image from", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            self.imagePicker.sourceType = .camera
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        cameraImageView.image = image
        cameraConfigEditor.image = image
        picker.dismiss(animated: true, completion: nil)
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
                    hRESButton.setTitle(val + " px", for: .normal)
                    cameraConfigEditor.hRES = Int(val) ?? 0
                } else if (src.updateTypeIdentifier == SingleValueEditViewController.lensVRESString) {
                    vRESButton.setTitle(val + " px", for: .normal)
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



