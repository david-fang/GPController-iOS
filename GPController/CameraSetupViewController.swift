//
//  CameraSetupViewController.swift
//  GPController
//
//  Created by David Fang on 7/6/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class CameraSetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: FadingTableView!
    
    var cameraConfigs: [CameraConfig] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCameraConfigsFromCoreData()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cameraConfigs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = cameraConfigs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cameraSelectionCell", for: indexPath) as! GPCamSelectionCell
        
        cell.identifierLabel.text = config.identifier
        cell.hFOVLabel.text = String(config.hFOV)
        cell.vFOVLabel.text = String(config.vFOV)
        cell.hRESLabel.text = String(config.hRES)
        cell.vRESLabel.text = String(config.vRES)
        cell.cameraImageView.image = UIImage(named: "Nikon3200")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableView.updateGradients()
    }
    
    func fetchCameraConfigsFromCoreData() {
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            cameraConfigs = try context.fetch(CameraConfig.fetchRequest())
        } catch {
            print("ERROR: Could not fetch cameras from CoreData")
        }
    }
    
}
