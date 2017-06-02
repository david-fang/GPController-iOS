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
            connected = false
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

    /**
     * This method sends the given test to the UART RX characteristic.
     * Depending on whether the characteristic has the Write Without Response or Write properties the behaviour is different.
     * In the latter case the Long Write may be used. To enable it you have to change the flag below in the code.
     * Otherwise, in both cases, texts longer than 20 (MTU) bytes (not characters) will be splitted into up-to 20-byte packets.
     *
     * - parameter aText: text to be sent to the peripheral using Nordic UART Service
     */
    func send(text aText : String) {
        guard self.uartRXCharacteristic != nil else {
            print("UART RX Characteristic not found")
            return
        }
        
        // Check what kind of Write Type is supported. By default it will try Without Response.
        // If the RX charactereisrtic have Write property the Write Request type will be used.
        var type = CBCharacteristicWriteType.withoutResponse
        if (self.uartRXCharacteristic!.properties.rawValue & CBCharacteristicProperties.write.rawValue) > 0 {
            type = CBCharacteristicWriteType.withResponse
        }
        
        // In case of Write Without Response the text needs to be splited in up-to 20-bytes packets.
        // When Write Request (with response) is used, the Long Write may be used.
        // It will be handled automatically by the iOS, but must be supported on the device side.
        // If your device does support Long Write, change the flag below to true.
        let longWriteSupported = false
        
        // The following code will split the text to packets
        let textData = aText.data(using: String.Encoding.utf8)!
        textData.withUnsafeBytes { (u8Ptr: UnsafePointer<CChar>) in
            var buffer = UnsafeMutableRawPointer(mutating: UnsafeRawPointer(u8Ptr))
            var len = textData.count
            
            while(len != 0){
                var part : String
                if len > MTU && (type == CBCharacteristicWriteType.withoutResponse || longWriteSupported == false) {
                    // If the text contains national letters they may be 2-byte long.
                    // It may happen that only 19 (MTU) bytes can be send so that not of them is splited into 2 packets.
                    var builder = NSMutableString(bytes: buffer, length: MTU, encoding: String.Encoding.utf8.rawValue)
                    if builder != nil {
                        // A 20-byte string has been created successfully
                        buffer  = buffer + MTU
                        len     = len - MTU
                    } else {
                        // We have to create 19-byte string. Let's ignore some stranger UTF-8 characters that have more than 2 bytes...
                        builder = NSMutableString(bytes: buffer, length: (MTU - 1), encoding: String.Encoding.utf8.rawValue)
                        buffer = buffer + (MTU - 1)
                        len    = len - (MTU - 1)
                    }
                    
                    part = String(describing: builder!)
                } else {
                    let builder = NSMutableString(bytes: buffer, length: len, encoding: String.Encoding.utf8.rawValue)
                    part = String(describing: builder!)
                    len = 0
                }
                send(text: part, withType: type)
            }
        }
    }
    
    /**
     * Sends the given text to the UART RX characteristic using the given write type.
     * This method does not split the text into parts. If the given write type is withResponse
     * and text is longer than 20-bytes the long write will be used.
     *
     * - parameters:
     *     - aText: text to be sent to the peripheral using Nordic UART Service
     *     - aType: write type to be used
     */
    func send(text aText : String, withType aType : CBCharacteristicWriteType) {
        guard self.uartRXCharacteristic != nil else {
            print("UART RX Characteristic not found")
            return
        }
        
        let typeAsString = aType == .withoutResponse ? ".withoutResponse" : ".withResponse"
        let data = aText.data(using: String.Encoding.utf8)!
        
        //do some logging
        print("Writing to characteristic: \(uartRXCharacteristic!.uuid.uuidString)")
        print("peripheral.writeValue(0x\(data.hexString), for: \(uartRXCharacteristic!.uuid.uuidString), type: \(typeAsString))")
        self.bluetoothPeripheral!.writeValue(data, for: self.uartRXCharacteristic!, type: aType)

        // The transmitted data is not available after the method returns. We have to log the text here.
        // The callback peripheral:didWriteValueForCharacteristic:error: is called only when the Write Request type was used,
        // but even if, the data is not available there.
        print("\"\(aText)\" sent")
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
            // FIX ME: Reset device here (turn LED off, for example)
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

            // REMOVE ME
            if (name == "GigaPan") {
                connectPeripheral(peripheral: peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(peripheral)
        cancelPeripheralConnection()
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Service discovery failed")
            //TODO: Disconnect?
            return
        }
        
        print("Services discovered")
        
        for aService: CBService in peripheral.services! {
            if aService.uuid.isEqual(UARTServiceUUID) {
                print("Nordic UART Service found")
                print("Discovering characteristics...")
                bluetoothPeripheral!.discoverCharacteristics(nil, for: aService)
                return
            }
        }

        //No UART service discovered
        print("UART Service not found. Try to turn bluetooth Off and On again to clear the cache.")
        delegate?.peripheralNotSupported()
        cancelPeripheralConnection()
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Characteristics discovery failed")
            print(error!)
            return
        }
        print("Characteristics discovered")
        
        if service.uuid.isEqual(UARTServiceUUID) {
            for aCharacteristic : CBCharacteristic in service.characteristics! {
                if aCharacteristic.uuid.isEqual(UARTTXCharacteristicUUID) {
                    print("TX Characteristic found")
                    uartTXCharacteristic = aCharacteristic
                } else if aCharacteristic.uuid.isEqual(UARTRXCharacteristicUUID) {
                    print("RX Characteristic found")
                    uartRXCharacteristic = aCharacteristic
                }
            }

            //Enable notifications on TX Characteristic
            if (uartTXCharacteristic != nil && uartRXCharacteristic != nil) {
                print("Enabling notifications for \(uartTXCharacteristic!.uuid.uuidString)")
                print("peripheral.setNotifyValue(true, for: \(uartTXCharacteristic!.uuid.uuidString))")
                bluetoothPeripheral!.setNotifyValue(true, for: uartTXCharacteristic!)
            } else {
                print("UART service does not have required characteristics. Try to turn Bluetooth Off and On again to clear cache.")
                delegate?.peripheralNotSupported()
                cancelPeripheralConnection()
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Enabling notifications failed")
            return
        }
        
        if characteristic.isNotifying {
            print("Notifications enabled for characteristic: \(characteristic.uuid.uuidString)")
        } else {
            print("Notifications disabled for characteristic: \(characteristic.uuid.uuidString)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Writing value to characteristic has failed")
            print(error!)
            return
        }

        print("Data written to characteristic: \(characteristic.uuid.uuidString)")
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Writing value to descriptor has failed")
            print(error!)
            return
        }

        print("Data written to descriptor: \(descriptor.uuid.uuidString)")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Updating characteristic has failed")
            print(error!)
            return
        }
        
        // try to print a friendly string of received bytes if they can be parsed as UTF8
        guard let bytesReceived = characteristic.value else {
            print("Notification received from: \(characteristic.uuid.uuidString), with empty value")
            print("Empty packet received")
            return
        }
        bytesReceived.withUnsafeBytes { (utf8Bytes: UnsafePointer<CChar>) in
            var len = bytesReceived.count
            if utf8Bytes[len - 1] == 0 {
                len -= 1    // if the string is null terminated, don't pass null terminator into 
                            // NSMutableString constructor
            }
            
            print("Notification received from: \(characteristic.uuid.uuidString), with value: 0x\(bytesReceived.hexString)")
            if let validUTF8String = String(utf8String: utf8Bytes) {//  NSMutableString(bytes: utf8Bytes, length: len, encoding: String.Encoding.utf8.rawValue) {
                print("\"\(validUTF8String)\" received")
            } else {
                print("\"0x\(bytesReceived.hexString)\" received")
            }
        }
    }
}