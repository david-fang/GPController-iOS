//
//  MainViewController.swift
//  GPController
//
//  Created by David Fang on 5/31/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth
import ChameleonFramework

class MainViewController: UIViewController, GPBluetoothManagerDelegate {

    @IBOutlet weak var dashboardContainer: UIView!
    @IBOutlet weak var headerContainer: UIView!
    
    @IBOutlet weak var connectButton: FlexiButton!
    @IBOutlet weak var panoramaButton: FlexiButton!
    @IBOutlet weak var controlButton: FlexiButton!
    @IBOutlet weak var savedConfigsButton: FlexiButton!
    @IBOutlet weak var changeMeLaterButton: FlexiButton!
    @IBOutlet weak var settingsButton: FlexiButton!

    var gpBTManager: GPBluetoothManager!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        gpBTManager = GPBluetoothManager()
        gpBTManager.delegate = self
        initCustomViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        updateMainView(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /** Set up the header and menu views */
    private func initCustomViews() {
        for button in [panoramaButton, controlButton, changeMeLaterButton, settingsButton] {
            button?.tintColor = .rushmoreBrown
        }

        connectButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
    }
    
    /** Update the header depending on whether or not a GigaPan device
        has been connected. */
    func updateMainView(animated: Bool) {
        let animationDuration = animated ? 0.7 : 0.0
        let connected = gpBTManager.isConnected()
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.connectButton.isUserInteractionEnabled = !connected
            self.connectButton.alpha = connected ? 0.0 : 1.0

            self.panoramaButton.isUserInteractionEnabled = connected
            self.controlButton.isUserInteractionEnabled = connected
        })
    }
 
    // MARK: - GPBluetoothManagerDelegate
    
    func peripheralReady() {
        DispatchQueue.main.async {
            self.updateMainView(animated: true)
        }
    }
    
    func didDisconnectPeripheral() {
        DispatchQueue.main.async {
            self.updateMainView(animated: true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMotorControl") {
            if let dest = segue.destination as? CameraPanViewController {
                dest.gpBTManager = self.gpBTManager
            }
        } else if (segue.identifier == "scanForDevices") {
            if let nc = segue.destination as? UINavigationController {
                if let dest = nc.childViewControllerForStatusBarHidden as? ScanDevicesViewController {
                    dest.gpBTManager = self.gpBTManager
               }
            }
        }
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        if (segue.identifier == "scannerToMain") {
            if let src = segue.source as? ScanDevicesViewController {
                if let peripheral = src.selectedPeripheral {
                    gpBTManager?.connectPeripheral(peripheral: peripheral)
                }
            }
        }
    }
}
