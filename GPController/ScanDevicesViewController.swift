//
//  ScanDevicesViewController.swift
//  GPController
//
//  Created by David Fang on 6/9/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanDevicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GPDeviceDiscoveryDelegate {

    @IBOutlet weak var noBluetoothView: UIView!
    @IBOutlet weak var devicesTableView: UITableView!

    var peripherals: [CBPeripheral] = []
    var selectedPeripheral: CBPeripheral?
    var gpBTManager: GPBluetoothManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        devicesTableView.delegate = self
        devicesTableView.dataSource = self
        devicesTableView.tableFooterView = UIView(frame: CGRect.zero)
        gpBTManager.scanner = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (gpBTManager.isEnabled()) {
            noBluetoothView.alpha = 0.0
            gpBTManager.scanForPeripherals(true)
        } else {
            noBluetoothView.alpha = 1.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func toggleBluetoothWarning(to on: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.noBluetoothView.alpha = on ? 1.0 : 0.0
        })
    }
    
    // MARK: - GPDeviceDiscoveryDelegate
    
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber) {
        if peripheral.name != nil {
            DispatchQueue.main.async(execute: {
                if ((self.peripherals.contains(peripheral)) == false) {
                    self.peripherals.append(peripheral)
                    self.devicesTableView.reloadData()
                }
            })
        }

    }
    
    func scannerMadeUnavailable() {
        DispatchQueue.main.async {
            self.toggleBluetoothWarning(to: true)
            self.gpBTManager.scanForPeripherals(false)  // Does nothing; Bluetooth already off
        }
    }
    
    func scannerMadeAvailable() {
        DispatchQueue.main.async {
            self.toggleBluetoothWarning(to: false)
            self.gpBTManager.scanForPeripherals(true)
        }
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
        gpBTManager.scanForPeripherals(false)
        performSegue(withIdentifier: "scannerToMain", sender: self)
    }
    
    // MARK: - Navigation
    
    @IBAction func returnToMain(_ sender: Any) {
        gpBTManager.scanForPeripherals(false)
        performSegue(withIdentifier: "scannerToMain", sender: self)
    }
}
