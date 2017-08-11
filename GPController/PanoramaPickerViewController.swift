/**
 *
 * PanoramaPickerViewController.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * Controller for panorama config setups. Responsible
 * for populating the table with all found PanoConfig
 * objects and providing information to the PanoForm
 * upon selection.
 *
 */

import UIKit

class PanoramaPickerViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    // MARK: - Subviews
    
    @IBOutlet weak var headerTextContainer: UIView!
    @IBOutlet weak var tableView: FadingTableView!

    // MARK: - Config Variables
    
    var camera: CameraConfig!
    var panoConfigs: [PanoConfig] = []
    var selectedConfig: PanoConfig?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 67
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPanoConfigsFromCoreData()
        tableView.reloadData()
        selectedConfig = nil
    }

    // MARK: - Table Population Functions

    /**
     * Populates the panoConfigs array with all saved CameraConfig
     * objects found in CoreData.
     */
    func fetchPanoConfigsFromCoreData() {
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            panoConfigs = try context.fetch(PanoConfig.fetchRequest())
        } catch {
            print("ERROR: Could not fetch panos from CoreData")
        }
    }

    // MARK: - TableViewDelegate / DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return panoConfigs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = panoConfigs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "panoSelectionCell", for: indexPath) as! GPPanoSelectionCell
        cell.identifierLabel.text = config.identifier

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedConfig = panoConfigs[indexPath.row]
        performSegue(withIdentifier: "toPanoForm", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction: UITableViewRowAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(self.panoConfigs[indexPath.row])
            appDelegate.saveContext()
            self.panoConfigs.remove(at: indexPath.row)
            
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
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func createNewConfig(_ sender: UIButton) {
        performSegue(withIdentifier: "toPanoForm", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toPanoForm") {
            if let dest = segue.destination as? PanoFormViewController {
                dest.camera = self.camera
                if selectedConfig != nil {
                    dest.selectedPano = self.selectedConfig
                }
            }
        }
    }
}
