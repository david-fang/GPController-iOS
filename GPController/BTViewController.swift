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

class BTViewController: UIViewController, CBCentralManagerDelegate, GPBluetoothManagerDelegate {

    @IBOutlet weak var dashboardContainer: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var connectButton: FlexiButton!
    
    @IBOutlet weak var panoramaButton: FlexiButton!
    @IBOutlet weak var controlButton: FlexiButton!
    @IBOutlet weak var changeMeLaterButton: FlexiButton!
    @IBOutlet weak var settingsButton: FlexiButton!
    
    var manager: CBCentralManager!
    var gpManager: GPBluetoothManager!
    var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let menuButtons: [UIButton] = [panoramaButton, controlButton, changeMeLaterButton, settingsButton]

        for button in menuButtons {
            button.tintColor = .rushmoreBrown
        }
        
        connectButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        
        manager = CBCentralManager(delegate: self, queue: nil)
        gpManager = GPBluetoothManager(withManager: manager)
        gpManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        // Figure out how to deal with this
    }
    
    func didConnectPeripheral(deviceName aName: String?) {
        // ADD
    }
    
    func didDisconnectPeripheral() {
        resetUI()
    }
    
    func peripheralReady() {
        performSegue(withIdentifier: "toMotorControl", sender: self)
    }
    
    func peripheralNotSupported() {
        // ADD
    }
    
    func resetUI() {
        // Set default configurations and views here; after device has
        // been discconnected
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMotorControl") {
            if let dest = segue.destination as? CameraPanViewController {
                dest.gpManager = self.gpManager
            }
        }
    }
    
    @IBAction func beginSearch(_ sender: UIButton) {
        // https://www.youtube.com/watch?v=B9sH_VxPPo4
        gpManager.startScanning()
    }
}
