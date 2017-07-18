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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segueToSingleEdit(sender: UIButton) {
        performSegue(withIdentifier: "singleEditCamConfig", sender: sender)
    }
    
    // MARK: - Navigation

    @IBAction func unwindToCameraForm(segue: UIStoryboardSegue) {
        if let src = segue.source as? SingleValueEditViewController {

            if let val = src.updatedValue {
                if (src.updateTypeIdentifier == SingleValueEditViewController.camIDString) {
                    identifierButton.setTitle(val, for: .normal)
                } else if (src.updateTypeIdentifier == SingleValueEditViewController.lensHRESString) {
                    hRESButton.setTitle(val, for: .normal)
                } else if (src.updateTypeIdentifier == SingleValueEditViewController.lensVRESString) {
                    vRESButton.setTitle(val, for: .normal)
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



