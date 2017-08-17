/**
 *
 * SingleValueEditViewController.swift
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

class SingleValueEditViewController: UIViewController {

    static let panoIDString = "PANO IDENTIFIER"
    static let camIDString = "CAM IDENTIFIER"
    static let lensHRESString = "LENS HRES"
    static let lensVRESString = "LENS VRES"
    
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var updateButton: UIButton!

    var updateTypeIdentifier: String!
    var updatedValue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateButton.setTitle("UPDATE " + String(updateTypeIdentifier), for: .normal)
        
        if (updateTypeIdentifier == SingleValueEditViewController.panoIDString || updateTypeIdentifier == SingleValueEditViewController.camIDString) {
            textfield.keyboardType = .default
        } else {
            textfield.keyboardType = .numberPad
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.textfield.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateValue(_ sender: Any) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }

        if (updateTypeIdentifier == SingleValueEditViewController.panoIDString ) {
            performSegue(withIdentifier: "unwindToPanoForm", sender: sender)
        } else {
            performSegue(withIdentifier: "unwindToCameraForm", sender: sender)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let text = textfield.text {
            if !text.isBlank {
                updatedValue = text
            }
        }
    }
}
