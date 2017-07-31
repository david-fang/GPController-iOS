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
    
    fileprivate let config:     CameraConfig?
    
    var identifier: String?
    var hFOV: Int
    var hRES: Int
    var vFOV: Int
    var vRES: Int
    
    init(config: CameraConfig) {
        self.config = config
        self.identifier = config.identifier!
        self.hFOV = Int(config.hFOV)
        self.hRES = Int(config.hRES)
        self.vFOV = Int(config.vFOV)
        self.vRES = Int(config.vRES)
    }
    
    init() {
        config = nil
        hFOV = 60
        hRES = 1440
        vFOV = 30
        vRES = 900
    }

    func identifierIsUnique(identifier: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let filterPred = NSPredicate(format: "\(core_identifierKey) == %@", identifier)
        let fetchRequest: NSFetchRequest<CameraConfig> = CameraConfig.fetchRequest()
        fetchRequest.predicate = filterPred
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            if (fetchResults.count > 0) {
                let queryConfig = fetchResults[0]
                
                if let config = self.config {
                    return queryConfig == config
                }
                
                return false
            }
        } catch {
            fatalError("Error fetching CameraConfig objects")
        }
        
        return true
    }
    
    func saveCameraConfig() -> Bool {
        guard let identifier = self.identifier else {
            fatalError("Cannot save a camera config with an empty identifier")
        }
        
        let cameraConfig: CameraConfig
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if (!identifierIsUnique(identifier: identifier)) {
            return false
        }
        
        if (self.config != nil) {
            cameraConfig = self.config!
        } else {
            cameraConfig = CameraConfig(context: context)
        }
        
        cameraConfig.setValue(identifier, forKey: core_identifierKey)
        cameraConfig.setValue(hFOV, forKey: core_hFOVKey)
        cameraConfig.setValue(vFOV, forKey: core_vFOVKey)
        cameraConfig.setValue(hRES, forKey: core_hRESKey)
        cameraConfig.setValue(vRES, forKey: core_vRESKey)
            
        appDelegate.saveContext()
        print("Saved config")

        return true
    }
}
