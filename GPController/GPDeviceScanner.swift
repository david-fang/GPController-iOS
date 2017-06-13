//
//  DeviceScannerDelegate.swift
//  GPController
//
//  Created by David Fang on 6/8/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol DeviceScannerDelegate {
    func centralManagerDidDiscoverPeripheral(_ peripheral: CBPeripheral, deviceRSSI: NSNumber)
}

class GPDeviceScanner: NSObject, CBCentralManagerDelegate {
    let dfuServiceUUIDString  = "00001530-1212-EFDE-1523-785FEABCD123"
    let ANCSServiceUUIDString = "7905F431-B5CE-4E99-A40F-4B1E122D00D0"

    var bluetoothManager : CBCentralManager!
    var delegate         : DeviceScannerDelegate?
    var filterUUID       : CBUUID?

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("Bluetooth is powered off")
            return
        }

        self.scanForPeripherals(true)
    }
    
    // MARK: - Bluetooth Functions
    
    func getConnectedPeripherals() -> [CBPeripheral] {
        guard let bluetoothManager = bluetoothManager else {
            return []
        }
        
        var retreivedPeripherals : [CBPeripheral]
        
        if filterUUID == nil {
            let dfuServiceUUID = CBUUID(string: dfuServiceUUIDString)
            let ancsServiceUUID = CBUUID(string: ANCSServiceUUIDString)
            retreivedPeripherals = bluetoothManager.retrieveConnectedPeripherals(withServices: [dfuServiceUUID, ancsServiceUUID])
        } else {
            retreivedPeripherals = bluetoothManager.retrieveConnectedPeripherals(withServices: [filterUUID!])
        }
        
        return retreivedPeripherals
    }
    
    /**
     * Starts scanning for peripherals with rscServiceUUID.
     * - parameter enable: If YES, this method will enable scanning for bridge devices, if NO it will stop scanning
     * - returns: true if success, false if Bluetooth Manager is not in CBCentralManagerStatePoweredOn state.
     */
    func scanForPeripherals(_ enable:Bool) {
        if (bluetoothManager.state == .poweredOn) {
            DispatchQueue.main.async {
                if enable == true {
                    let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
                    if self.filterUUID != nil {
                        self.bluetoothManager?.scanForPeripherals(withServices: [self.filterUUID!], options: options as? [String : AnyObject])
                    } else {
                        self.bluetoothManager?.scanForPeripherals(withServices: nil, options: options as? [String : AnyObject])
                    }
                } else {
                    self.bluetoothManager?.stopScan()
                }
            }
        }
    }
    
    /** DELEGATES **/
    
    //MARK: - CBCentralManager Functions

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.delegate?.centralManagerDidDiscoverPeripheral(peripheral, deviceRSSI: RSSI)
    }
}
