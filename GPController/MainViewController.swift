/**
 *
 * MainViewController.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * Controller for the main view. Primarily acts as a landing
 * screen for creating the Bluetooth manager for the first time
 * and handling navigation to the scanner, manual control, and
 * session views.
 *
 */

import UIKit
import CoreBluetooth
import ChameleonFramework

class MainViewController: UIViewController, GPBluetoothManagerDelegate {

    // MARK: - Subviews
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet var navigationButtons: [FlexiButton]!
    @IBOutlet weak var bluetoothButton: FlexiButton!

    // MARK: - Bluetooth Variables
    
    var gpBTManager: GPBluetoothManager!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadBootupAnimations(completion: {
            self.gpBTManager = GPBluetoothManager()
            self.gpBTManager.delegate = self
        }, delayBy: 0.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - GPBluetoothManagerDelegate

    func peripheralReady() {
        DispatchQueue.main.async {
            self.bluetoothButton.setImage(#imageLiteral(resourceName: "bluetooth_gold"), for: .normal)
        }
    }

    func didDisconnectPeripheral() {
        DispatchQueue.main.async {
            self.bluetoothButton.setImage(#imageLiteral(resourceName: "bluetooth_white"), for: .normal)
        }
    }
    
    // MARK: - Navigation

    @IBAction func segueToManualControl(_ sender: UIButton) {
        if let manager = gpBTManager {
            if manager.isConnected() {
                performSegue(withIdentifier: "toManualControl", sender: sender)
                return
            }
        }

        let alert = UIAlertController(title: "No device connected", message: "This feature requires a connected device. Please connect to a GigaPan device to continue.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func segueToScanner(_ sender: UIButton) {
        performSegue(withIdentifier: "toDeviceScanner", sender: sender)
    }

    @IBAction func segueToSetup(_ sender: UIButton) {
        performSegue(withIdentifier: "toSessionSetup", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toManualControl") {
            if let dest = segue.destination as? ManualControlViewController {
                dest.gpBTManager = self.gpBTManager
            }
        } else if (segue.identifier == "toDeviceScanner") {
            if let nc = segue.destination as? UINavigationController {
                if let dest = nc.childViewControllerForStatusBarHidden as? DeviceScannerViewController {
                    dest.gpBTManager = self.gpBTManager
               }
            }
        } else if (segue.identifier == "toSessionSetup") {
            if let nc = segue.destination as? GPNavigationController {
                if (nc.childViewControllerForStatusBarHidden as? CameraPickerViewController) != nil {
                    nc.gpBTManager = self.gpBTManager
                }
            }
        }
    }
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {
        if (segue.identifier == "scannerToMain") {
            if let src = segue.source as? DeviceScannerViewController {
                if let peripheral = src.selectedPeripheral {
                    gpBTManager?.connectPeripheral(peripheral: peripheral)
                }
            }
        }
    }
    
    // MARK: - View Update Functions

    /**
     * Performs view's loadup animations. Includes the button popup and
     * logo fade in.
     *
     * - Parameter completion: Completion handler for post-bootup
     * - Parameter delayBy: Amount of time in seconds to delay the completion handler
     */
    fileprivate func loadBootupAnimations(completion: (() -> Void)?, delayBy delayInterval: Double) {
        for button in navigationButtons {
            button.isUserInteractionEnabled = false
            button.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
        
        titleView.alpha = 0
        
        let panoButton = navigationButtons[0]
        let manualButton = navigationButtons[1]
        let connectButton = navigationButtons[2]
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut], animations: {
            panoButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut], animations: {
                panoButton.transform = CGAffineTransform.identity
                manualButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { _ in
                UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut], animations: {
                    manualButton.transform = CGAffineTransform.identity
                    connectButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut], animations: {
                        connectButton.transform = CGAffineTransform.identity
                    }, completion: { _ in
                        UIView.animate(withDuration: 1.0, animations: {
                            self.titleView.alpha = 1
                        }, completion: { _ in
                            delay(delayInterval, closure: {
                                completion?()
                            })

                            for button in self.navigationButtons {
                                button.isUserInteractionEnabled = true
                            }
                        })
                    })
                })
            })
        })
    }

}
