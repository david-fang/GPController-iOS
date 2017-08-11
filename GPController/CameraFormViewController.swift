/**
 *
 * CameraFormViewController.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * Controller for creating, previewing, and editing
 * CameraConfigs. This controller handles access to 
 * the photo library or camera and enforces valid config 
 * inputs before saving.
 *
 */

import UIKit

class CameraFormViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: - Subviews
    
    @IBOutlet weak var identifierButton: UIButton!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var hRESButton: UIButton!
    @IBOutlet weak var vRESButton: UIButton!
    @IBOutlet weak var hFOVStepper: GMStepper!
    @IBOutlet weak var vFOVStepper: GMStepper!

    var imagePicker: UIImagePickerController!
    var loadingOverlay: UIAlertController?

    // MARK: - Config Variables
    
    var cameraConfig: CameraConfig?
    var cameraConfigEditor: CameraConfigEditor!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // If this view was loaded as a result of a config selection
        // from the CameraPicker view, then load its values onto
        // the form. Otherwise, create a new config with default values
        // and load those values instead.

        if let config = cameraConfig {
            cameraConfigEditor = CameraConfigEditor(config: config)
        } else {
            cameraConfigEditor = CameraConfigEditor()
        }
        
        cameraImageView.image = cameraConfigEditor.image
        hFOVStepper.value = cameraConfigEditor.hFOV
        vFOVStepper.value = cameraConfigEditor.vFOV
        hRESButton.setTitle(String(cameraConfigEditor.hRES) + " px", for: .normal)
        vRESButton.setTitle(String(cameraConfigEditor.vRES) + " px", for: .normal)
        
        if let identifier = cameraConfigEditor.identifier {
            identifierButton.setTitle(identifier, for: .normal)
        } else {
            identifierButton.setTitle("What should I name this?", for: .normal)
        }
    }

    /** 
     * Creates the loading screen during config updates.
     *
     * - Parameter completion: completion handler after loading
     *      screen is presented
     */
    func displayLoadingPopup(completion: (() -> Void)?) {
        loadingOverlay = UIAlertController(title: nil, message: "Updating...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        loadingOverlay!.view.addSubview(loadingIndicator)
        present(loadingOverlay!, animated: true, completion: completion)
    }
    
    /** Removes the loading screen. */
    func removeLoadingPopup(completion: (() -> Void)?) {
        loadingOverlay?.dismiss(animated: true, completion: completion)
    }
    
    // MARK: - Editing I/O Handlers
    
    @IBAction func updateHFOV(_ sender: GMStepper) {
        cameraConfigEditor.hFOV = hFOVStepper.value
    }
    
    @IBAction func updatevFOV(_ sender: GMStepper) {
        cameraConfigEditor.vFOV = vFOVStepper.value
    }
    
    /** 
     * Updates the CameraConfig to reflect the changes on the form.
     * Responsible for checking invalid input before giving the
     * CameraConfigEditor the thumbs up to save.
     *
     * - Parameter sender: the save button
     */
    @IBAction func saveCameraConfig(_ sender: UIButton) {
        
        // Enforces that the field of view for the camera lens is not zero
        if (cameraConfigEditor.hFOV == 0 || cameraConfigEditor.vFOV == 0) {
            let alert = UIAlertController(title: "Missing fields", message: "Camera configuration cannot have field of view of 0", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))

            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Enforces that the config identifier is not left blank
        if cameraConfigEditor.identifier == nil {
            let alert = UIAlertController(title: "Missing fields", message: "Camera configuration cannot be saved without an identifier", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // If the CameraConfig could not be saved, the identifier must already exist
        // and an error screen will be created to notify the user.
        displayLoadingPopup { 
            self.cameraConfigEditor.saveCameraConfig { (success) in
                if (success) {
                    self.removeLoadingPopup(completion: {
                        self.performSegue(withIdentifier: "toPanoramaSetup", sender: self)
                    })
                } else {
                    self.removeLoadingPopup(completion: {
                        let alert = UIAlertController(title: "Invalid identifier", message: "The desired identifier is already being used by an existing configuration", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }

        }
    }

    /**
      * Creates an action sheet with image picking options and a
      * UIImagePickerController to handle the actual photo selection.
      *
      * - Parameter sender: a button element to start the selection process
      */
    @IBAction func selectImage(_ sender: UIButton) {
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Option to take your own photo
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action: UIAlertAction) in
            self.imagePicker.sourceType = .camera
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        
        // Option to choose a photo from the photo library
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        
        // Option to remove the current photo and go back to the default
        actionSheet.addAction(UIAlertAction(title: "Delete Photo", style: .default, handler: { (action: UIAlertAction) in
            self.cameraImageView.image = #imageLiteral(resourceName: "DefaultCamera")
            self.cameraConfigEditor.setImage(to: #imageLiteral(resourceName: "DefaultCamera"))
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage

        cameraImageView.image = image
        cameraConfigEditor.setImage(to: image)

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "singleEditCamConfig") {
            guard let dest = segue.destination as? SingleValueEditViewController, let sender = sender as? UIButton else {
                return
            }

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

        } else if (segue.identifier == "toPanoramaSetup") {
            guard let dest = segue.destination as? PanoramaPickerViewController, let selectedConfig = cameraConfigEditor.getCameraConfig() else {
                return
            }

            dest.camera = selectedConfig
        }
    }
}




