//
//  DevicesTableViewController.swift
//  GPController
//
//  Created by David Fang on 6/8/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesTableViewController: UITableViewController, GPDeviceDiscoveryDelegate {

    var gpBTManager: GPBluetoothManager!
    var peripherals: [CBPeripheral] = []
    var selectedPeripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        gpBTManager.scanner = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gpBTManager.scanForPeripherals(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber) {
        if peripheral.name != nil {
            DispatchQueue.main.async(execute: {
                if ((self.peripherals.contains(peripheral)) == false) {
                    print("\(peripheral.name)")
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
        selectedPeripheral = peripherals[indexPath.row]
        gpBTManager.scanForPeripherals(false)
        performSegue(withIdentifier: "menuToMain", sender: self)
    }
    
    // MARK: - Navigation
    
    @IBAction func returnToMain(_ sender: Any) {
        gpBTManager.scanForPeripherals(false)
        performSegue(withIdentifier: "menuToMain", sender: self)
    }
}
