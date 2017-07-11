//
//  PanoFormViewController.swift
//  GPController
//
//  Created by David Fang on 7/11/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class PanoFormViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {

    @IBOutlet var editView: UIView!
    @IBOutlet var mainView: UIView!

    @IBOutlet weak var identifierTextfield: GPTextField!

    @IBOutlet weak var colStepper: GMStepper!
    @IBOutlet weak var rowStepper: GMStepper!

    @IBOutlet weak var angleInput: UITextField!
    @IBOutlet weak var tiltInput: UITextField!
    @IBOutlet weak var hOverlapInput: UITextField!
    @IBOutlet weak var vOverlapInput: UITextField!

    @IBOutlet weak var columnsStepper: GMStepper!
    @IBOutlet weak var rowsStepper: GMStepper!

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func showEditView() {
        mainView.isHidden = true
        editView.center = view.center
        editView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(editView)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        continueButton.setTitle("✓", for: .normal)
        backButton.isHidden = true
    }
    
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
                // do something
            } else if (title == "→") {
                // perform segue here
                showEditView()
            }
        }
    }
    
}
