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
    
    fileprivate var config: CameraConfig?

    var identifier: String?
    var image: UIImage
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

        if let imageData = config.imageData {
            if let image = UIImage(data: imageData as Data) {
                self.image = image
                return
            }
        }
        
        self.image = #imageLiteral(resourceName: "DefaultCamera")
    }
    
    init() {
        self.config = nil
        self.hFOV = 60
        self.hRES = 1440
        self.vFOV = 30
        self.vRES = 900
        self.image = #imageLiteral(resourceName: "DefaultCamera")
    }

    func getCameraConfig() -> CameraConfig? {
        return config
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
    
    func saveCameraConfig(completion: ((_ success: Bool) -> Void)?) {
        guard let identifier = self.identifier else {
            fatalError("Cannot save a camera config with an empty identifier")
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if (!identifierIsUnique(identifier: identifier)) {
            completion?(false)
            return
        }
        
        if (self.config == nil) {
            self.config = CameraConfig(context: context)
        }
        
        let imageData = UIImageJPEGRepresentation(self.image, 1)

        config!.setValue(identifier, forKey: core_identifierKey)
        config!.setValue(hFOV, forKey: core_hFOVKey)
        config!.setValue(vFOV, forKey: core_vFOVKey)
        config!.setValue(hRES, forKey: core_hRESKey)
        config!.setValue(vRES, forKey: core_vRESKey)
        config!.setValue(imageData, forKey: core_imageDataKey)
        
        appDelegate.saveContext()
        completion?(true)
    }
}
