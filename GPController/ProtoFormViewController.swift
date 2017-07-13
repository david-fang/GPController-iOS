//
//  ProtoFormViewController.swift
//  GPController
//
//  Created by David Fang on 7/12/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class ProtoFormViewController: UIViewController {

    @IBOutlet weak var identifierButton: UIButton!

    @IBOutlet weak var hOverlapStepper: GMStepper!
    @IBOutlet weak var vOverlapStepper: GMStepper!
    @IBOutlet weak var rowStepper: GMStepper!
    @IBOutlet weak var panStepper: GMStepper!
    @IBOutlet weak var colStepper: GMStepper!
    @IBOutlet weak var tiltStepper: GMStepper!

    @IBOutlet weak var horSemiFullCheckbox: CheckboxButton!
    @IBOutlet weak var horFullCheckbox: CheckboxButton!
    @IBOutlet weak var verSemiFullCheckbox: CheckboxButton!
    @IBOutlet weak var verFullCheckbox: CheckboxButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        identifierButton.layer.cornerRadius = 4.0
        identifierButton.clipsToBounds = true
        
//        identifierButton.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        hOverlapStepper.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        vOverlapStepper.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        
//        horSemiFullCheckbox.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        
//        horFullCheckbox.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        verSemiFullCheckbox.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        
//        verFullCheckbox.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        
//        rowStepper.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        panStepper.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        colStepper.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        tiltStepper.addDropShadow(color: UIColor.darkGray, offset: CGSize(width: 0, height: 7), opacity: 0.3, radius: 4.0)
//        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
