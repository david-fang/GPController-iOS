//
//  GPBluetoothManager.swift
//  GPController
//
//  Created by David Fang on 6/1/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol GPBluetoothManagerDelegate {
    func didConnectPeripheral(deviceName aName : String?)
    func didDisconnectPeripheral()
    func peripheralReady()
    func peripheralNotSupported()
}

class GPBluetoothManager: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {

    // MARK: - Delegate Properties
    var delegate: GPBluetoothManagerDelegate?
    
    // MARK: - Class Properties
    fileprivate let MTU = 20
    fileprivate let UARTServiceUUID             : CBUUID
    fileprivate let UARTRXCharacteristicUUID    : CBUUID
    fileprivate let UARTTXCharacteristicUUID    : CBUUID
    
    fileprivate var centralManager              : CBCentralManager
    fileprivate var bluetoothPeripheral         : CBPeripheral?
    fileprivate var uartRXCharacteristic        : CBCharacteristic?
    fileprivate var uartTXCharacteristic        : CBCharacteristic?


    fileprivate var connected = false
    
    // MARK: - BluetoothManager API
    
    required init(withManager aManager : CBCentralManager) {
        centralManager = aManager
        UARTServiceUUID          = CBUUID(string: ServiceIdentifiers.uartServiceUUIDString)
        UARTTXCharacteristicUUID = CBUUID(string: ServiceIdentifiers.uartTXCharacteristicUUIDString)
        UARTRXCharacteristicUUID = CBUUID(string: ServiceIdentifiers.uartRXCharacteristicUUIDString)
        super.init()
        
        centralManager.delegate = self
    }

    /**
     * Connects to the given peripheral.
     *
     * - parameter aPeripheral: target peripheral to connect to
     */
    func connectPeripheral(peripheral aPeripheral : CBPeripheral) {
        bluetoothPeripheral = aPeripheral

        if let name = aPeripheral.name {
            print("Connecting to: \(name)...")
        } else {
            print("Connecting to unnamed device...")
        }

        centralManager.connect(aPeripheral, options: nil)
    }

    /**
     * Disconnects or cancels pending connection.
     * The delegate's didDisconnectPeripheral() method will be called when device got disconnected.
     */
    func cancelPeripheralConnection() {
        guard bluetoothPeripheral != nil else {
            print("Peripheral not set")
            return
        }
        if connected {
            print("Disconnecting...")
        } else {
            print("Cancelling connection...")
        }

        centralManager.cancelPeripheralConnection(bluetoothPeripheral!)
        
        // In case the previous connection attempt failed before establishing a connection
        if !connected {
            bluetoothPeripheral = nil
            delegate?.didDisconnectPeripheral()
        }
    }
    
    /**
     * Returns true if the peripheral device is connected, false otherwise
     * - returns: true if device is connected
     */
    func isConnected() -> Bool {
        return connected
    }

    /** Start scanning for connectable devices */
    func startScanning() {
        print("Scanning...")
        centralManager.scanForPeripherals(withServices: [UARTServiceUUID], options: nil)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var state : String
        switch(central.state){
        case .poweredOn:
            state = "Powered ON"
            break
        case .poweredOff:
            state = "Powered OFF"
            break
        case .resetting:
            state = "Resetting"
            break
        case .unauthorized:
            state = "Unautthorized"
            break
        case .unsupported:
            state = "Unsupported"
            break
        case .unknown:
            state = "Unknown"
            break
        }
        
        print("Central Manager did update state to: \(state)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[Callback] Central Manager did connect peripheral")
        if let name = peripheral.name {
            print("[x] Connected to: \(name)")
        } else {
            print("[x] Connected to unnamed device")
        }
        
        connected = true
        bluetoothPeripheral = peripheral
        bluetoothPeripheral!.delegate = self
        delegate?.didConnectPeripheral(deviceName: peripheral.name)
        print("Discovering services...")
        print("peripheral.discoverServices([\(UARTServiceUUID.uuidString)])")
        peripheral.discoverServices([UARTServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name {
            print(name)
            
            if (name == "GigaPan") {
                connectPeripheral(peripheral: peripheral)
            }
        }
    }
    
    //MARK: - CBPeripheralDelegate
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard error == nil else {
//            log(withLevel: .warningLogLevel, andMessage: "Service discovery failed")
//            logError(error: error!)
//            //TODO: Disconnect?
//            return
//        }
//        
//        log(withLevel: .infoLogLevel, andMessage: "Services discovered")
//        
//        for aService: CBService in peripheral.services! {
//            if aService.uuid.isEqual(UARTServiceUUID) {
//                log(withLevel: .verboseLogLevel, andMessage: "Nordic UART Service found")
//                log(withLevel: .verboseLogLevel, andMessage: "Discovering characteristics...")
//                log(withLevel: .debugLogLevel, andMessage: "peripheral.discoverCharacteristics(nil, for: \(aService.uuid.uuidString))")
//                bluetoothPeripheral!.discoverCharacteristics(nil, for: aService)
//                return
//            }
//        }
//        
//        //No UART service discovered
//        log(withLevel: .warningLogLevel, andMessage: "UART Service not found. Try to turn bluetooth Off and On again to clear the cache.")
//        delegate?.peripheralNotSupported()
//        cancelPeripheralConnection()
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard error == nil else {
//            log(withLevel: .warningLogLevel, andMessage: "Characteristics discovery failed")
//            logError(error: error!)
//            return
//        }
//        log(withLevel: .infoLogLevel, andMessage: "Characteristics discovered")
//        
//        if service.uuid.isEqual(UARTServiceUUID) {
//            for aCharacteristic : CBCharacteristic in service.characteristics! {
//                if aCharacteristic.uuid.isEqual(UARTTXCharacteristicUUID) {
//                    log(withLevel: .verboseLogLevel, andMessage: "TX Characteristic found")
//                    uartTXCharacteristic = aCharacteristic
//                } else if aCharacteristic.uuid.isEqual(UARTRXCharacteristicUUID) {
//                    log(withLevel: .verboseLogLevel, andMessage: "RX Characteristic found")
//                    uartRXCharacteristic = aCharacteristic
//                }
//            }
//            //Enable notifications on TX Characteristic
//            if (uartTXCharacteristic != nil && uartRXCharacteristic != nil) {
//                log(withLevel: .verboseLogLevel, andMessage: "Enabling notifications for \(uartTXCharacteristic!.uuid.uuidString)")
//                log(withLevel: .debugLogLevel, andMessage: "peripheral.setNotifyValue(true, for: \(uartTXCharacteristic!.uuid.uuidString))")
//                bluetoothPeripheral!.setNotifyValue(true, for: uartTXCharacteristic!)
//            } else {
//                log(withLevel: .warningLogLevel, andMessage: "UART service does not have required characteristics. Try to turn Bluetooth Off and On again to clear cache.")
//                delegate?.peripheralNotSupported()
//                cancelPeripheralConnection()
//            }
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        guard error == nil else {
//            log(withLevel: .warningLogLevel, andMessage: "Enabling notifications failed")
//            logError(error: error!)
//            return
//        }
//        
//        if characteristic.isNotifying {
//            log(withLevel: .infoLogLevel, andMessage: "Notifications enabled for characteristic: \(characteristic.uuid.uuidString)")
//        } else {
//            log(withLevel: .infoLogLevel, andMessage: "Notifications disabled for characteristic: \(characteristic.uuid.uuidString)")
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        guard error == nil else {
//            log(withLevel: .warningLogLevel, andMessage: "Writing value to characteristic has failed")
//            logError(error: error!)
//            return
//        }
//        log(withLevel: .infoLogLevel, andMessage: "Data written to characteristic: \(characteristic.uuid.uuidString)")
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
//        guard error == nil else {
//            log(withLevel: .warningLogLevel, andMessage: "Writing value to descriptor has failed")
//            logError(error: error!)
//            return
//        }
//        log(withLevel: .infoLogLevel, andMessage: "Data written to descriptor: \(descriptor.uuid.uuidString)")
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        guard error == nil else {
//            log(withLevel: .warningLogLevel, andMessage: "Updating characteristic has failed")
//            logError(error: error!)
//            return
//        }
//        
//        // try to print a friendly string of received bytes if they can be parsed as UTF8
//        guard let bytesReceived = characteristic.value else {
//            log(withLevel: .infoLogLevel, andMessage: "Notification received from: \(characteristic.uuid.uuidString), with empty value")
//            log(withLevel: .appLogLevel, andMessage: "Empty packet received")
//            return
//        }
//        bytesReceived.withUnsafeBytes { (utf8Bytes: UnsafePointer<CChar>) in
//            var len = bytesReceived.count
//            if utf8Bytes[len - 1] == 0 {
//                len -= 1 // if the string is null terminated, don't pass null terminator into NSMutableString constructor
//            }
//            
//            log(withLevel: .infoLogLevel, andMessage: "Notification received from: \(characteristic.uuid.uuidString), with value: 0x\(bytesReceived.hexString)")
//            if let validUTF8String = String(utf8String: utf8Bytes) {//  NSMutableString(bytes: utf8Bytes, length: len, encoding: String.Encoding.utf8.rawValue) {
//                log(withLevel: .appLogLevel, andMessage: "\"\(validUTF8String)\" received")
//            } else {
//                log(withLevel: .appLogLevel, andMessage: "\"0x\(bytesReceived.hexString)\" received")
//            }
//        }
//    }
}
