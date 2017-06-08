//
//  DeviceScannerDelegate.swift
//  GPController
//
//  Created by David Fang on 6/8/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol DeviceScannerDelegate {
    func centralManagerDidSelectPeripheral(withManager aManager: CBCentralManager, andPeripheral aPeripheral: CBPeripheral)
}
