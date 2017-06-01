//
//  BTViewController.swift
//  GPController
//
//  Created by David Fang on 5/31/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth

class BTViewController: UIViewController, CBCentralManagerDelegate {
    
    var manager: CBCentralManager!
    var gpManager: GPBluetoothManager!
    var peripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil)
        gpManager = GPBluetoothManager(withManager: manager)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        // Figure out how to deal with this
    }
    
    @IBAction func beginSearch(_ sender: LoadingButton) {
        sender.changeState(toState: .Loading)
        gpManager.startScanning()
        sender.progress = 1.0
    }
}
