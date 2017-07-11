//
//  PanoFormViewController.swift
//  GPController
//
//  Created by David Fang on 7/11/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class PanoFormViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Edit View
    
    @IBOutlet var editView: UIView!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var digitPicker: UIPickerView!
    @IBOutlet weak var digitPickerWidth: NSLayoutConstraint!

    // MARK: - Main View

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

    fileprivate func showEditView() {
        mainView.isHidden = true
        editView.center = view.center
        editView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        digitPicker.delegate = self
        digitPicker.dataSource = self
        // digitPicker.selectRow(<#T##row: Int##Int#>, inComponent: <#T##Int#>, animated: <#T##Bool#>)

        view.addSubview(editView)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        continueButton.setTitle("✓", for: .normal)
        backButton.isHidden = true
    }
    
    // MARK: - Picker View Delegates
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: String(row), attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 30.0)!])

        return attributedString
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        inputLabel.text = "\(digitPicker.selectedRow(inComponent: 0))\(digitPicker.selectedRow(inComponent: 1))\(digitPicker.selectedRow(inComponent: 2)) %"
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
                // do something
            } else if (title == "→") {
                // perform segue here
                showEditView()
            }
        }
    }
    
}
