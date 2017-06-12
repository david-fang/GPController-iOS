//
//  ScanDevicesViewController.swift
//  GPController
//
//  Created by David Fang on 6/9/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanDevicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DeviceScannerDelegate {

    @IBOutlet weak var noBluetoothView: UIView!
    @IBOutlet weak var devicesTableView: UITableView!

    var peripherals: [CBPeripheral] = []
    var selectedPeripheral: CBPeripheral?
    var scanner: GPDeviceScanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        devicesTableView.delegate = self
        devicesTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (scanner.bluetoothIsOn) {
            bluetoothMadeAvailable()
        } else {
            bluetoothMadeUnavailable()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func toggleBluetoothWarning(to on: Bool) {
        UIView.animate(withDuration: 1.0, animations: {
            self.noBluetoothView.alpha = on ? 1.0 : 0.0
        })
    }
    
    // MARK: - DeviceScannerDelegate
    
    func centralManagerDidDiscoverPeripheral(peripheral: CBPeripheral, deviceRSSI: NSNumber) {
        if peripheral.name != nil {
            DispatchQueue.main.async(execute: {
                if ((self.peripherals.contains(peripheral)) == false) {
                    self.peripherals.append(peripheral)
                    self.devicesTableView.reloadData()
                }
            })
        }
    }
    
    func bluetoothMadeUnavailable() {
        print("Notification made. Turning on warning.")
        DispatchQueue.main.async {
            self.toggleBluetoothWarning(to: true)
        }

        scanner.scanForPeripherals(false)
    }
    
    func bluetoothMadeAvailable() {
        print("Notification made. Turning off warning.")
        DispatchQueue.main.async {
            self.toggleBluetoothWarning(to: false)
        }
        
        peripherals = scanner.getConnectedPeripherals()
        devicesTableView.reloadData()
        scanner.scanForPeripherals(true)
    }
    
    // MARK: - TableViewDataSource / TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = devicesTableView.dequeueReusableCell(withIdentifier: "discoveredDeviceCell", for: indexPath)
        cell.textLabel?.text = peripherals[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPeripheral = peripherals[indexPath.row]
        scanner.scanForPeripherals(false)
        performSegue(withIdentifier: "scannerToMain", sender: self)
    }
    
    // MARK: - Navigation
    
    @IBAction func returnToMain(_ sender: Any) {
        scanner.scanForPeripherals(false)
        performSegue(withIdentifier: "scannerToMain", sender: self)
    }
}
