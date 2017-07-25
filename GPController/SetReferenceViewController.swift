//
//  SetReferenceViewController.swift
//  GPController
//
//  Created by David Fang on 7/24/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class SetReferenceViewController: UIViewController {
    
    @IBOutlet var moveToStartView: UIView!
    @IBOutlet var editReferenceView: UIView!
    @IBOutlet var previewView: UIView!

    @IBOutlet weak var displaySection: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showSubview(_ sender: Any) {
        view.addSubview(editReferenceView)
        editReferenceView.bounds = displaySection.bounds
        editReferenceView.center = displaySection.center
    }
    
    
    @IBAction func moveGigaPan(_ sender: RoundAxisButton) {
        
    }
    

}
