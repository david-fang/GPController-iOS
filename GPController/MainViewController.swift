//
//  BTViewController.swift
//  GPController
//
//  Created by David Fang on 5/31/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth
import ChameleonFramework

class MainViewController: UIViewController, CBCentralManagerDelegate, GPBluetoothManagerDelegate {

    @IBOutlet weak var dashboardContainer: UIView!
    @IBOutlet weak var headerContainer: UIView!
    
    @IBOutlet weak var connectButton: FlexiButton!
    @IBOutlet weak var panoramaButton: FlexiButton!
    @IBOutlet weak var controlButton: FlexiButton!
    @IBOutlet weak var changeMeLaterButton: FlexiButton!
    @IBOutlet weak var settingsButton: FlexiButton!

    var gpBTManager: GPBluetoothManager!
    var connected: Bool = false {
        didSet {
            updateHeader(withDetails: connected)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let centralQueue = DispatchQueue(label: "GPCtrl.ble", attributes: [])
        let centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        gpBTManager = GPBluetoothManager(withManager: centralManager)

        initCustomViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /** Set up the header and menu views */
    private func initCustomViews() {
        for button in [panoramaButton, controlButton, changeMeLaterButton, settingsButton] {
            button?.tintColor = .rushmoreBrown
        }
        updateHeader(withDetails: false)
    }
    
    /** Update the header depending on whether or not a GigaPan device
        has been connected. */
    private func updateHeader(withDetails shouldShowDetails: Bool) {
        if (shouldShowDetails) {
            
        } else {
            connectButton.isUserInteractionEnabled = true
            connectButton.alpha = 1.0
            connectButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // IGNORE
    }
    
    // MARK: - GPBluetoothManagerDelegate
    
    func didConnectPeripheral(deviceName aName: String?) {
        connected = true
    }
    
    func didDisconnectPeripheral() {
        connected = false
    }
 
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMotorControl") {
            if let dest = segue.destination as? CameraPanViewController {
                dest.gpBTManager = self.gpBTManager
            }
        } else if (segue.identifier == "scanForDevices") {
            if let nc = segue.destination as? UINavigationController {
                if let dest = nc.childViewControllerForStatusBarHidden as? DevicesTableViewController {
                    dest.gpBTManager = self.gpBTManager
               }
            }
        }
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        if (segue.identifier == "menuToMain") {
            if let src = segue.source as? DevicesTableViewController {
                if let peripheral = src.selectedPeripheral {
                    gpBTManager?.connectPeripheral(peripheral: peripheral)
                }
            }
        }
    }
}
