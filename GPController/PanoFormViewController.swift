//
//  PanoFormViewController.swift
//  GPController
//
//  Created by David Fang on 7/11/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class PanoFormViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Main View

    @IBOutlet var mainView: UIView!

    @IBOutlet weak var identifierTextfield: GPTextField!

    @IBOutlet weak var colStepper: GMStepper!
    @IBOutlet weak var rowStepper: GMStepper!
    @IBOutlet weak var panStepper: GMStepper!
    @IBOutlet weak var tiltStepper: GMStepper!
    @IBOutlet weak var hOverlapStepper: GMStepper!
    @IBOutlet weak var vOverlapStepper: GMStepper!

    @IBOutlet weak var h180Checkbox: CheckboxButton!
    @IBOutlet weak var h360Checkbox: CheckboxButton!
    @IBOutlet weak var v180Checkbox: CheckboxButton!
    @IBOutlet weak var v360Checkbox: CheckboxButton!
    
    @IBOutlet weak var continueButton: FlexiButton!
    @IBOutlet weak var backButton: FlexiButton!
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
            statusBar.backgroundColor = UIColor.black
        }
        
        identifierTextfield.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        continueButton.setTitle("✓", for: .normal)
    }
    
    fileprivate func dismissKeyboard() {
        view.endEditing(true)
        continueButton.setTitle("→", for: .normal)
    }
    
    // MARK: - Update/Editing Functions
    
    @IBAction func panoTypeWasSelected(_ sender: CheckboxButton) {
        if (sender == h180Checkbox && h180Checkbox.on) {
            h360Checkbox.on = false
        } else if (sender == h360Checkbox && h360Checkbox.on) {
            h180Checkbox.on = false
        } else if (sender == v180Checkbox && v180Checkbox.on) {
            v360Checkbox.on = false
        } else if (sender == v360Checkbox && v360Checkbox.on) {
            v180Checkbox.on = false
        }
    }
    
    @IBAction func doneButtonWasPressed(_ sender: UIButton) {
        if let title = sender.currentTitle {
            if (title == "✓") {
                dismissKeyboard()
            } else if (title == "→") {
                // perform segue here
            }
        }
    }
    
}
