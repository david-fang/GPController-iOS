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
    
    let blurEffectView = UIVisualEffectView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        devicesTableView.delegate = self
        devicesTableView.dataSource = self
        devicesTableView.tableFooterView = UIView(frame: CGRect.zero)
        devicesTableView.separatorStyle = .none
        
        gpBTManager.scanner = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (gpBTManager.isEnabled()) {
            toggleBluetoothWarning(to: false)
            gpBTManager.scanForPeripherals(true)
        } else {
            toggleBluetoothWarning(to: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func toggleBluetoothWarning(to on: Bool) {
        if (on) {
            self.view.popupSubview(subview: noBluetoothView, blurEffectView: blurEffectView)
        } else {
            self.view.closePopup(subview: noBluetoothView, blurEffectView: blurEffectView, completion: nil)
        }
    }
    
    // MARK: - GPDeviceDiscoveryDelegate
    
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber) {
        if peripheral.name != nil {
            DispatchQueue.main.async(execute: {
                if ((self.peripherals.contains(peripheral)) == false) {
                    self.peripherals.append(peripheral)
                    
                    self.devicesTableView.beginUpdates()
                    self.devicesTableView.insertRows(at: [IndexPath(row: self.peripherals.count - 1, section: 0)], with: .automatic)
                    self.devicesTableView.endUpdates()
                    
                    // self.devicesTableView.reloadData()
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
        let peripheral = peripherals[indexPath.row]
        let cell = devicesTableView.dequeueReusableCell(withIdentifier: "discoveredDeviceCell", for: indexPath) as! ScannedDeviceCell
        
        if let name = peripheral.name {
            cell.deviceIdentifier.text = "◆  \(name)"
        } else {
            cell.deviceIdentifier.text = "◆  Unidentified"
        }

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
