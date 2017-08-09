//
//  MainViewController.swift
//  GPController
//
//  Created by David Fang on 5/31/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import CoreBluetooth
import ChameleonFramework

class MainViewController: UIViewController, GPBluetoothManagerDelegate {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet var navigationButtons: [FlexiButton]!

    var gpBTManager: GPBluetoothManager!
    var transition: JTMaterialTransition?

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - GPBluetoothManagerDelegate
    
    func peripheralReady() {
        // Connected
    }

    func didDisconnectPeripheral() {
        // Disconnected
    }
    
    // MARK: - Navigation

    @IBAction func segueToManualControl(_ sender: UIButton) {
        performSegue(withIdentifier: "toManualControl", sender: transition)
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
                if let dest = nc.childViewControllerForStatusBarHidden as? ScanDevicesViewController {
                    dest.gpBTManager = self.gpBTManager
               }
            }
        } else if (segue.identifier == "toSessionSetup") {
            if let nc = segue.destination as? GPNavigationController {
                if let dest = nc.childViewControllerForStatusBarHidden as? CameraSetupViewController {
                    nc.gpBTManager = self.gpBTManager
                }
            }
        }
    }
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {
        if (segue.identifier == "scannerToMain") {
            if let src = segue.source as? ScanDevicesViewController {
                if let peripheral = src.selectedPeripheral {
                    gpBTManager?.connectPeripheral(peripheral: peripheral)
                }
            }
        }
    }
    
    // MARK: - View Update Functions

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
