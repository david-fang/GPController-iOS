//
//  CameraConfigEditor.swift
//  GPController
//
//  Created by David Fang on 7/18/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CameraConfigEditor {
    
    var identifier: String
    var hFOV: Int
    var hRES: Int
    var vFOV: Int
    var vRES: Int
    
    init() {
        identifier = ""
        hFOV = 60
        hRES = 1440
        vFOV = 30
        vRES = 900
    }
    
    func saveCameraConfig() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let filterPred = NSPredicate(format: "\(core_identifierKey) == %@", self.identifier)
        let fetchRequest: NSFetchRequest<CameraConfig> = CameraConfig.fetchRequest()
        fetchRequest.predicate = filterPred
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            let cameraConfig: CameraConfig
            
            if (fetchResults.count < 1) {
                cameraConfig = CameraConfig(context: context)
            } else {
                cameraConfig = fetchResults[0]
                print("Found one")
            }
            
            cameraConfig.setValue(identifier, forKey: core_identifierKey)
            cameraConfig.setValue(hFOV, forKey: core_hFOVKey)
            cameraConfig.setValue(vFOV, forKey: core_vFOVKey)
            cameraConfig.setValue(hRES, forKey: core_hRESKey)
            cameraConfig.setValue(vRES, forKey: core_vRESKey)
            
            appDelegate.saveContext()
            
            print("Saved config!")
            
        } catch {
            print("Error fetching CameraConfig object")
            return
        }
    }
    
}
