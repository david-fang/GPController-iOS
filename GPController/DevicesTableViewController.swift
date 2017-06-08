//
//  DevicesTableViewController.swift
//  GPController
//
//  Created by David Fang on 6/8/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesTableViewController: UITableViewController, CBCentralManagerDelegate {
    let dfuServiceUUIDString  = "00001530-1212-EFDE-1523-785FEABCD123"
    let ANCSServiceUUIDString = "7905F431-B5CE-4E99-A40F-4B1E122D00D0"

    var bluetoothManager : CBCentralManager?
    var delegate         : DeviceScannerDelegate?
    var filterUUID       : CBUUID?
    var peripherals      : [CBPeripheral] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        let centralQueue = DispatchQueue(label: "GPCtrl.devicescan", attributes: [])
        bluetoothManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let success = self.scanForPeripherals(false)
        if !success {
            print("Bluetooth is powered off!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    func scanForPeripherals(_ enable:Bool) -> Bool {
        guard bluetoothManager?.state == .poweredOn else {
            return false
        }

        DispatchQueue.main.async {
            if enable == true {
                let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
                if self.filterUUID != nil {
                    self.bluetoothManager?.scanForPeripherals(withServices: [self.filterUUID!], options: options as? [String : AnyObject])
                } else {
                    self.bluetoothManager?.scanForPeripherals(withServices: nil, options: options as? [String : AnyObject])
                }
                
                self.tableView.reloadData()
            } else {
                self.bluetoothManager?.stopScan()
            }
        }
        
        return true
    }
    
    /** DELEGATES **/
    
    //MARK: - CBCentralManager Functions

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("Bluetooth is powered off")
            return
        }
        
        let connectedPeripherals = self.getConnectedPeripherals()
        var newScannedPeripherals: [CBPeripheral] = []
        connectedPeripherals.forEach { (connectedPeripheral: CBPeripheral) in
            let scannedPeripheral = connectedPeripheral
            newScannedPeripherals.append(scannedPeripheral)
        }

        peripherals = newScannedPeripherals
        let success = self.scanForPeripherals(true)
        if !success {
            print("Bluetooth is powered off!")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if peripheral.name != nil {
            DispatchQueue.main.async(execute: {
                if ((self.peripherals.contains(peripheral)) == false) {
                    self.peripherals.append(peripheral)
                    self.tableView.reloadData()
                }
            })
        }
    }

    // MARK: - TableView Functions

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        cell.textLabel?.text = peripherals[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bluetoothManager?.stopScan()

        let peripheral = peripherals[indexPath.row]
        self.delegate?.centralManagerDidSelectPeripheral(withManager: bluetoothManager!, andPeripheral: peripheral)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    @IBAction func returnToMain(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
