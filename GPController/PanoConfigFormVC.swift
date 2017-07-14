//
//  ProtoFormViewController.swift
//  GPController
//
//  Created by David Fang on 7/12/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class PanoConfigFormVC: UIViewController {

    @IBOutlet weak var identifierButton: UIButton!
    @IBOutlet weak var componentsStepper: GMStepper!
    @IBOutlet weak var fovStepper: GMStepper!
    @IBOutlet weak var overlapStepper: GMStepper!
    
    let hFOV: Double = 70
    let hOverlap: Double = 60
    let hLensFOV: Double = 90
    let vFOV: Double = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        identifierButton.layer.cornerRadius = 4.0
        identifierButton.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

