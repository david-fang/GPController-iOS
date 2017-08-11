/**
 *
 * GPNavigationController.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * The navigation controller used for the panorama session
 * views.
 *
 * IMPORTANT: Holds a reference to the GPBluetoothManager used
 * to communicate with the GigaPan's Bluetooth module. This
 * design allows for sessions views within this navigation
 * controller to share the same manager without having to pass
 * them around in segues every time.
 *
 */
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
}
