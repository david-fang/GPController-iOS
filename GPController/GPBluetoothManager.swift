//
//  GPBluetoothManager.swift
//  GPController
//
//  Created by David Fang on 6/1/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc protocol GPDeviceDiscoveryDelegate {
    @objc func didDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber)
    @objc func scannerMadeAvailable()
    @objc func scannerMadeUnavailable()
}

@objc protocol GPBluetoothManagerDelegate {
    @objc optional func didConnectPeripheral(deviceName aName : String?)
    @objc optional func didDisconnectPeripheral()
    @objc optional func peripheralReady()
    @objc optional func peripheralNotSupported()
}

@objc protocol GPMotorManagerInterruptDelegate {
    @objc func deviceDidDisconnect()
    // @objc func deviceDidReconnect()
    @objc func bluetoothDidDisable()
}

class GPBluetoothManager: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {

    // MARK: - Delegate Properties
    var delegate: GPBluetoothManagerDelegate?
    var scanner: GPDeviceDiscoveryDelegate?

    // MARK: - Class Properties
    fileprivate let MTU = 20
    fileprivate let UARTServiceUUID             : CBUUID
    fileprivate let UARTRXCharacteristicUUID    : CBUUID
    fileprivate let UARTTXCharacteristicUUID    : CBUUID
    fileprivate var filterUUID                  : CBUUID
    
    fileprivate var centralManager              : CBCentralManager!
    fileprivate var bluetoothPeripheral         : CBPeripheral?
    fileprivate var uartRXCharacteristic        : CBCharacteristic?
    fileprivate var uartTXCharacteristic        : CBCharacteristic?

    fileprivate var connected = false
    fileprivate let centralQueue = DispatchQueue(label: "GPCtrl.ble", attributes: [])

    // MARK: - BluetoothManager API

    required override init() {
        UARTServiceUUID          = CBUUID(string: ServiceIdentifiers.uartServiceUUIDString)
        UARTTXCharacteristicUUID = CBUUID(string: ServiceIdentifiers.uartTXCharacteristicUUIDString)
        UARTRXCharacteristicUUID = CBUUID(string: ServiceIdentifiers.uartRXCharacteristicUUIDString)
        filterUUID               = UARTServiceUUID
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
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
            if let name = bluetoothPeripheral?.name {
                print("Disconnecting from \(name)...")
            }
            connected = false
        } else {
            print("Cancelling connection...")
        }

        centralManager.cancelPeripheralConnection(bluetoothPeripheral!)
        
        // In case the previous connection attempt failed before establishing a connection
        if !connected {
            bluetoothPeripheral = nil
            delegate?.didDisconnectPeripheral?()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        scanner?.didDiscoverPeripheral(peripheral, RSSI: RSSI)
    }
    
    /**
     * Returns true if the peripheral device is connected, false otherwise
     * - returns: true if device is connected
     */
    func isConnected() -> Bool {
        return connected
    }
    
    /**
     * Returns true if bluetooth capabilities are turned on, false otherwise
     * - returns: true if bluetooth is on
     */
    func isEnabled() -> Bool {
        return centralManager.state == .poweredOn
    }
    
    // MARK: - Scanner API

    /**
     * Starts scanning for peripherals with rscServiceUUID.
     * - parameter enable: If YES, this method will enable scanning for bridge devices, if NO it will stop scanning
     * - returns: true if success, false if Bluetooth Manager is not in CBCentralManagerStatePoweredOn state.
     */
    func scanForPeripherals(_ enable:Bool) {
        if (centralManager.state == .poweredOn) {
            DispatchQueue.main.async {
                if enable == true {
                    let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
                    self.centralManager.scanForPeripherals(withServices: [self.filterUUID], options: options as? [String : AnyObject])
                } else {
                    self.centralManager.stopScan()
                }
            }
        }
    }
    
    func getConnectedPeripherals() -> [CBPeripheral] {
        let retreivedPeripherals : [CBPeripheral] = centralManager.retrieveConnectedPeripherals(withServices: [filterUUID])
        return retreivedPeripherals
    }

    // MARK: - Data Sending API
    
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
        
        print("Writing to characteristic: \(uartRXCharacteristic!.uuid.uuidString)")
        print("peripheral.writeValue(0x\(data.hexString), for: \(uartRXCharacteristic!.uuid.uuidString), type: \(typeAsString))")
        self.bluetoothPeripheral!.writeValue(data, for: self.uartRXCharacteristic!, type: aType)
        
        print("\"\(aText)\" sent")
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
        
        var type = CBCharacteristicWriteType.withoutResponse
        if (self.uartRXCharacteristic!.properties.rawValue & CBCharacteristicProperties.write.rawValue) > 0 {
            type = CBCharacteristicWriteType.withResponse
        }

        let longWriteSupported = false
        
        let textData = aText.data(using: String.Encoding.utf8)!
        textData.withUnsafeBytes { (u8Ptr: UnsafePointer<CChar>) in
            var buffer = UnsafeMutableRawPointer(mutating: UnsafeRawPointer(u8Ptr))
            var len = textData.count
            
            while(len != 0){
                var part : String
                if len > MTU && (type == CBCharacteristicWriteType.withoutResponse || longWriteSupported == false) {
                    var builder = NSMutableString(bytes: buffer, length: MTU, encoding: String.Encoding.utf8.rawValue)
                    if builder != nil {
                        buffer  = buffer + MTU
                        len     = len - MTU
                    } else {
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

    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var state : String
        switch(central.state){
        case .poweredOn:
            state = "Powered ON"
            scanner?.scannerMadeAvailable()
            break
        case .poweredOff:
            state = "Powered OFF"
            scanner?.scannerMadeUnavailable()
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
        delegate?.didConnectPeripheral?(deviceName: peripheral.name)
        print("Discovering services...")
        print("peripheral.discoverServices([\(UARTServiceUUID.uuidString)])")
        peripheral.discoverServices([UARTServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if let error = error {
            print(error)
        }

        cancelPeripheralConnection()
    }
    
    // MARK: - CBPeripheral Delegate
    
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

        print("UART Service not found. Try to turn bluetooth Off and On again to clear the cache.")
        delegate?.peripheralNotSupported?()
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

            if (uartTXCharacteristic != nil && uartRXCharacteristic != nil) {
                print("Enabling notifications for \(uartTXCharacteristic!.uuid.uuidString)")
                print("peripheral.setNotifyValue(true, for: \(uartTXCharacteristic!.uuid.uuidString))")
                bluetoothPeripheral!.setNotifyValue(true, for: uartTXCharacteristic!)
            } else {
                print("UART service does not have required characteristics. Try to turn Bluetooth Off and On again to clear cache.")
                delegate?.peripheralNotSupported?()
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
        
        delegate?.peripheralReady?()
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
        
        guard let bytesReceived = characteristic.value else {
            print("Notification received from: \(characteristic.uuid.uuidString), with empty value")
            print("Empty packet received")
            return
        }
        bytesReceived.withUnsafeBytes { (utf8Bytes: UnsafePointer<CChar>) in
            var len = bytesReceived.count
            if utf8Bytes[len - 1] == 0 {
                len -= 1
            }
            
            print("Notification received from: \(characteristic.uuid.uuidString), with value: 0x\(bytesReceived.hexString)")
            
            // Callback write received through this function
            
            if let validUTF8String = String(utf8String: utf8Bytes) {
                print("\"\(validUTF8String)\" received")
            } else {
                print("\"0x\(bytesReceived.hexString)\" received")
            }
        }
    }
}
