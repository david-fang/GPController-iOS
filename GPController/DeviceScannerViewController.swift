/**
 *
 * DeviceScannerViewController.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * Controller for the device scanner view. Handles the device
 * discovery and device selection.
 *
 */

import UIKit
import CoreBluetooth

class DeviceScannerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GPDeviceDiscoveryDelegate, UIScrollViewDelegate {

    // MARK: - Subviews
    
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var devicesTableView:FadingTableView!
    @IBOutlet weak var bluetoothStatusLabel: UILabel!
    @IBOutlet weak var linearProgressBarContainer: UIView!

    var linearProgressBar: LinearProgressBar!
    let blurEffectView = UIVisualEffectView()

    // MARK: - Bluetooth Variables
    
    var peripherals: [CBPeripheral] = []
    var selectedPeripheral: CBPeripheral?
    var gpBTManager: GPBluetoothManager!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        linearProgressBar = LinearProgressBar(frame: linearProgressBarContainer.frame)
        linearProgressBar.backgroundColor = UIColor.clear
        linearProgressBar.backgroundProgressBarColor = UIColor.clear
        linearProgressBar.progressBarColor = UIColor.cyarkGold

        devicesTableView.delegate = self
        devicesTableView.dataSource = self
        devicesTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: devicesTableView.frame.width, height: 12))
        devicesTableView.tableFooterView?.backgroundColor = UIColor.clear
        devicesTableView.separatorStyle = .none
        devicesTableView.clipsToBounds = false
        devicesTableView.layer.masksToBounds = false

        gpBTManager.scanner = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (gpBTManager.isEnabled()) {
            toggleBluetoothWarning(to: false)
            self.linearProgressBar.startAnimation()
            gpBTManager.scanForPeripherals(true)
        } else {
            toggleBluetoothWarning(to: true)
        }
    }
    
    /**
     * Updates the status label based on the device's Bluetooth
     * availablility.
     *
     * - Parameter on: true if Bluetooth is available; false otherwise
     */
    fileprivate func toggleBluetoothWarning(to on: Bool) {
        if (on) {
            bluetoothStatusLabel.text = "Please enable Bluetooth"
        } else {
            bluetoothStatusLabel.text = "Scanning for devices..."
        }
    }

    // MARK: - GPDeviceDiscoveryDelegate

    func didDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber) {
        if peripheral.name != nil {
            DispatchQueue.main.async(execute: {
                if ((self.peripherals.contains(peripheral)) == false) {
                    self.peripherals.append(peripheral)

                    self.devicesTableView.beginUpdates()
                    self.devicesTableView.insertRows(at: [IndexPath(row: self.peripherals.count - 1, section: 0)], with: .left)
                    self.devicesTableView.endUpdates()                    
                }
            })
        }

    }
    
    func scannerMadeUnavailable() {
        DispatchQueue.main.async {
            self.toggleBluetoothWarning(to: true)
            self.linearProgressBar.stopAnimation()
            self.gpBTManager.scanForPeripherals(false)
        }
    }

    func scannerMadeAvailable() {
        DispatchQueue.main.async {
            self.toggleBluetoothWarning(to: false)
            self.linearProgressBar.startAnimation()
            self.gpBTManager.scanForPeripherals(true)
        }
    }

    // MARK: - TableViewDelegate / DataSource

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
        linearProgressBar.stopAnimation()
        gpBTManager.scanForPeripherals(false)
        performSegue(withIdentifier: "scannerToMain", sender: self)
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        devicesTableView.updateGradients()
    }

    // MARK: - Navigation

    @IBAction func returnToMain(_ sender: Any) {
        linearProgressBar.stopAnimation()
        gpBTManager.scanForPeripherals(false)
        performSegue(withIdentifier: "scannerToMain", sender: self)
    }
}
