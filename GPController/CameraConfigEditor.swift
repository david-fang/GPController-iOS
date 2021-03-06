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
    
    fileprivate var imageDataWasTouched: Bool = false
    
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
        self.hFOV = DEFAULT_LENS_HFOV
        self.hRES = DEFAULT_LENS_HRES
        self.vFOV = DEFAULT_LENS_VFOV
        self.vRES = DEFAULT_LENS_VRES
        self.image = #imageLiteral(resourceName: "DefaultCamera")
    }

    func getCameraConfig() -> CameraConfig? {
        return config
    }
    
    func setImage(to image: UIImage) {
        self.image = image
        imageDataWasTouched = true
    }

    func identifierIsUnique(identifier: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let filterPred = NSPredicate(format: "\(CoreKeys.identifier) == %@", identifier)
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
        
        if (imageDataWasTouched) {
            let imageData = UIImageJPEGRepresentation(self.image, 1)
            config!.setValue(imageData, forKey: CoreKeys.imageData)
        }

        config!.setValue(identifier, forKey: CoreKeys.identifier)
        config!.setValue(hFOV, forKey: CoreKeys.hfov)
        config!.setValue(vFOV, forKey: CoreKeys.vfov)
        config!.setValue(hRES, forKey: CoreKeys.hres)
        config!.setValue(vRES, forKey: CoreKeys.vres)
        
        appDelegate.saveContext()
        completion?(true)
    }
}
