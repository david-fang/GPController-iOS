//
//  PanoramaSettingsViewController.swift
//  GPController
//
//  Created by David Fang on 7/5/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class PanoramaSetupViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var headerTextContainer: UIView!
    @IBOutlet weak var tableView: FadingTableView!

    var panoConfigs: [PanoConfig] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTextContainer.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: headerTextContainer.frame, andColors: [UIColor.flatSand, UIColor.sandpaperWhite])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPanoConfigsFromCoreData()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
        cell.rowsLabel.text = String(config.rows)
        cell.hFOVLabel.text = String(config.hFOV)
        cell.hOverlapLabel.text = String(config.hOverlap)
        cell.columnsLabel.text = String(config.columns)
        cell.vFOVLabel.text = String(config.vFOV)
        cell.vOverlapLabel.text = String(config.vOverlap)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableView.updateGradients()
    }
    
    func fetchPanoConfigsFromCoreData() {
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            panoConfigs = try context.fetch(PanoConfig.fetchRequest())
        } catch {
            print("ERROR: Could not fetch panos from CoreData")
        }
    }
}
