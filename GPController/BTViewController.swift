//
//  BTViewController.swift
//  GPController
//
//  Created by David Fang on 5/31/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth

class BTViewController: UIViewController, CBCentralManagerDelegate, GPBluetoothManagerDelegate {
    
    var manager: CBCentralManager!
    var gpManager: GPBluetoothManager!
    var peripheral: CBPeripheral!
    
    @IBOutlet weak var ledSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        // ADD
    }
    
    func peripheralNotSupported() {
        // ADD
    }
    
    func resetUI() {
        ledSwitch.setOn(false, animated: true)
    }
    
    @IBAction func beginSearch(_ sender: LoadingButton) {
        sender.changeState(toState: .Loading)
        gpManager.startScanning()
        sender.progress = 1.0
    }

    @IBAction func switchLED(_ sender: UISwitch) {
        
        if (sender.isOn) {
            gpManager.send(text: "1")
        } else {
            gpManager.send(text: "0")
        }
    }
}
