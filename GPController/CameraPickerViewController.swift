/**
 *
 * CameraPickerViewController.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * Controller for camera config selections. Responsible
 * for populating the table with all found CameraConfig 
 * objects and providing information to the CameraForm
 * upon selection.
 *
 */

import UIKit

class CameraPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    // MARK: - Subviews
    
    @IBOutlet weak var headerTextContainer: UIView!
    @IBOutlet weak var tableView: FadingTableView!
    
    // MARK: Config Variables
    
    var cameraConfigs: [CameraConfig] = []
    var selectedConfig: CameraConfig?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 12))
        tableView.tableFooterView?.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCameraConfigsFromCoreData()
        tableView.reloadData()
    }
    
    // MARK: - Table Population Functions
    
    /**
     * Populates the cameraConfigs array with all saved CameraConfig
     * objects found in CoreData.
     */
    func fetchCameraConfigsFromCoreData() {
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            cameraConfigs = try context.fetch(CameraConfig.fetchRequest())
        } catch {
            print("ERROR: Could not fetch cameras from CoreData")
        }
    }
    
    // MARK: - TableViewDelegate / DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cameraConfigs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = cameraConfigs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cameraSelectionCell", for: indexPath) as! GPCamSelectionCell
        var cellImg: UIImage = #imageLiteral(resourceName: "DefaultCamera")
        
        DispatchQueue.main.async {
            cell.identifierLabel.text = config.identifier
            cell.hFOVLabel.text = String(config.hFOV) + "°"
            cell.vFOVLabel.text = String(config.vFOV) + "°"
            cell.hRESLabel.text = String(config.hRES) + "px"
            cell.vRESLabel.text = String(config.vRES) + "px"

            if let imageData = config.imageData {
                if let image = UIImage(data: imageData as Data) {
                    cellImg = image
                }
            }
            
            cell.cameraImageView.image = cellImg
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedConfig = cameraConfigs[indexPath.row]
        performSegue(withIdentifier: "toCameraForm", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction: UITableViewRowAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(self.cameraConfigs[indexPath.row])
            appDelegate.saveContext()
            self.cameraConfigs.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        
        deleteAction.backgroundColor = UIColor.clear

        return [deleteAction]
    }

    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableView.updateGradients()
    }
    
    // MARK: - Navigation
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if let nc = self.navigationController as? GPNavigationController {
                nc.gpBTManager = nil
            }

            self.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func createNewConfig(_ sender: UIButton) {
        selectedConfig = nil
        performSegue(withIdentifier: "toCameraForm", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCameraForm") {
            if let dest = segue.destination as? CameraFormViewController {
                if let selectedConfig = selectedConfig {
                    dest.cameraConfig = selectedConfig
                }
            }
        }
    }
    
    
}
