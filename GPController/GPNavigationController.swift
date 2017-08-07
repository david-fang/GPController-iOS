//
//  GPNavigationControllerViewController.swift
//  GPController
//
//  Created by David Fang on 6/8/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class GPNavigationController: UINavigationController {

    @IBInspectable var shouldHideNavigationBar: Bool = false
    
    var gpBTManager: GPBluetoothManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        if (shouldHideNavigationBar) {
            self.setNavigationBarHidden(true, animated: false)
        } else {
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.isTranslucent = true
        }
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
