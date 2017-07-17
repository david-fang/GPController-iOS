//
//  PanoramaSettingsViewController.swift
//  GPController
//
//  Created by David Fang on 7/5/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class PanoramaSetupViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var headerTextContainer: UIView!
    @IBOutlet weak var tableView: FadingTableView!
    
    fileprivate let cellPadding = 16    // As specified in storyboard
    fileprivate let numRowsToShow = 3   // ... at startup
    
    var panoConfigs: [PanoConfig] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTextContainer.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: headerTextContainer.frame, andColors: [UIColor.sandpaperWhite, UIColor.flatSand])
        
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
        // return panoConfigs.count
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "panoSelectionCell", for: indexPath) as! GPPanoSelectionCell
        
        // print(panoConfigs[indexPath.row].columns)
        // print(panoConfigs[indexPath.row].rows)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return
            tableView.frame.height / CGFloat(numRowsToShow)
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
            print("ERROR: Could not fetch tasks from CoreData")
        }
    }
}
