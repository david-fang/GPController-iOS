//
//  PanoramaSettingsViewController.swift
//  GPController
//
//  Created by David Fang on 7/5/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class PanoramaSetupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var identifierTextfield: UITextField!
    @IBOutlet weak var rowsCountLabel: UILabel!
    @IBOutlet weak var columnsCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupView() {
        rowsCountLabel.layer.borderWidth = 1.0
        rowsCountLabel.layer.borderColor = UIColor.darkGray.cgColor
        columnsCountLabel.layer.borderWidth = 1.0
        columnsCountLabel.layer.borderColor = UIColor.darkGray.cgColor
    }

    @IBAction func changeCount(_ sender: UIStepper) {
        let label: UILabel = sender.tag == 0 ? rowsCountLabel : columnsCountLabel
        label.text = String(Int(sender.value))
    }
    
}
