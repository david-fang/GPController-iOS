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

class MainViewController: UIViewController, GPBluetoothManagerDelegate, DeviceScannerDelegate {

    @IBOutlet weak var dashboardContainer: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var connectButton: FlexiButton!
    
    @IBOutlet weak var panoramaButton: FlexiButton!
    @IBOutlet weak var controlButton: FlexiButton!
    @IBOutlet weak var changeMeLaterButton: FlexiButton!
    @IBOutlet weak var settingsButton: FlexiButton!
    
    var gpManager: GPBluetoothManager!
    var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let menuButtons: [UIButton] = [panoramaButton, controlButton, changeMeLaterButton, settingsButton]

        for button in menuButtons {
            button.tintColor = .rushmoreBrown
        }
        
        connectButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func didConnectPeripheral(deviceName aName: String?) {
        // ADD
    }
    
    func didDisconnectPeripheral() {
        resetUI()
    }
    
    func peripheralReady() {
        // ADD
    }
    
    func peripheralNotSupported() {
        // ADD
    }
    
    func resetUI() {
        // Set default configurations and views here; after device has
        // been discconnected
    }
    
    
    // MARK: Device Scanner Delegate
    func centralManagerDidSelectPeripheral(withManager aManager: CBCentralManager, andPeripheral aPeripheral: CBPeripheral) {
        print("Making manager")
        gpManager = GPBluetoothManager(withManager: aManager)
        gpManager.delegate = self
        print("Made manager")
        gpManager.connectPeripheral(peripheral: aPeripheral)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMotorControl") {
            if let dest = segue.destination as? CameraPanViewController {
                dest.gpManager = self.gpManager
            }
        } else if (segue.identifier == "scanForDevices") {
//            let nc = segue.destination as! UINavigationController
//            let controller = nc.childViewControllerForStatusBarHidden as! NORScannerViewController
            if let dest = segue.destination as? DevicesTableViewController {
                dest.delegate = self
            }
        }
    }

    @IBAction func beginSearch(_ sender: UIButton) {
        // https://www.youtube.com/watch?v=B9sH_VxPPo4
        // gpManager.startScanning()
    }
}
