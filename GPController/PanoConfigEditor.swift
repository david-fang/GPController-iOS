//
//  PanoramaConfiguration.swift
//  GPController
//
//  Created by David Fang on 7/15/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PanoConfigEditor {
    
    struct PanoValueSet {
        let components: Int
        let fov: Int
        let overlap: Int
        
        init(components: Int, fov: Int, overlap: Int) {
            self.components = components
            self.fov = fov
            self.overlap = overlap
        }
    }
    
    struct PanoLockSet {
        let componentsLock: Bool
        let fovLock: Bool
        let overlapLock: Bool
        
        init(componentsLock: Bool, fovLock: Bool, overlapLock: Bool) {
            self.componentsLock = componentsLock
            self.fovLock = fovLock
            self.overlapLock = overlapLock
        }
    }
    
    fileprivate let config:         PanoConfig?
    fileprivate var identifier:     String?

    // HORIZONTAL SETTINGS

    fileprivate var rows:           Int
    fileprivate var hFOV:           Int
    fileprivate var hOverlap:       Int
    fileprivate var rowsLock:       Bool
    fileprivate var hFOVLock:       Bool
    fileprivate var hOverlapLock:   Bool

    // VERTICAL SETTINGS
    
    fileprivate var columns:        Int
    fileprivate var vFOV:           Int
    fileprivate var vOverlap:       Int
    fileprivate var columnsLock:    Bool
    fileprivate var vFOVLock:       Bool
    fileprivate var vOverlapLock:   Bool
    
    init(config: PanoConfig, camHFOV: Int, camVFOV: Int) {
        self.config = config

        identifier = config.identifier!

        columns = Int(config.columns)
        hFOV = Int(config.hFOV)
        hOverlap = Int(config.hOverlap)
        columnsLock = config.columnsLock
        hFOVLock = config.hFOVLock
        hOverlapLock = config.hOverlapLock

        rows = Int(config.rows)
        vFOV = Int(config.vFOV)
        vOverlap = Int(config.vOverlap)
        rowsLock = config.rowsLock
        vFOVLock = config.vFOVLock
        vOverlapLock = config.vOverlapLock
        
        if (columnsLock && hFOVLock) {
            hOverlap = GPCalculate.overlap(numComponents: columns, panoFOV: hFOV, lensFOV: camHFOV)
        } else if (columnsLock && hOverlapLock) {
            hFOV = GPCalculate.panoFOV(numComponents: columns, lensFOV: camHFOV, overlap: hOverlap)
        } else if (hFOVLock && hOverlapLock) {
            columns = GPCalculate.numComponents(panoFOV: hFOV, lensFOV: camHFOV, overlap: hOverlap)
        }
        
        if (rowsLock && vFOVLock) {
            vOverlap = GPCalculate.overlap(numComponents: rows, panoFOV: vFOV, lensFOV: camVFOV)
        } else if (rowsLock && vOverlapLock) {
            vFOV = GPCalculate.panoFOV(numComponents: rows, lensFOV: camVFOV, overlap: vOverlap)
        } else if (vFOVLock && vOverlapLock) {
            rows = GPCalculate.numComponents(panoFOV: vFOV, lensFOV: camVFOV, overlap: vOverlap)
        }
        
    }
    
    init(camHFOV: Int, camVFOV: Int) {
        let numRows = GPCalculate.numComponents(panoFOV: DEFAULT_PANO_HFOV, lensFOV: camHFOV, overlap: DEFAULT_PANO_OVERLAP)
        let numColumns = GPCalculate.numComponents(panoFOV: DEFAULT_PANO_VFOV, lensFOV: camVFOV, overlap: DEFAULT_PANO_OVERLAP)

        config = nil

        columns = numColumns
        hFOV = DEFAULT_PANO_HFOV
        hOverlap = DEFAULT_PANO_OVERLAP
        columnsLock = true
        hFOVLock = true
        hOverlapLock = false
        
        rows = numRows
        vFOV = DEFAULT_PANO_VFOV
        vOverlap = DEFAULT_PANO_OVERLAP
        rowsLock = true
        vFOVLock = true
        vOverlapLock = false
    }

    
    /** 
     * Returns true if the update was successful. Returns false
     * if the identifier already exists for another panorama.
     */
    func setIdentifier(to id: String?) {
        identifier = id
    }
    
    func setComponents(for axis: Axis, to value: Int) {
        switch axis {
        case .horizontal:
            columns = value
        case .vertical:
            rows = value
        }
    }
    
    func setFieldOfView(for axis: Axis, to value: Int) {
        switch axis {
        case .horizontal:
            hFOV = value
        default:
            vFOV = value
        }
    }
    
    func setOverlap(for axis: Axis, to value: Int) {
        switch axis {
        case .horizontal:
            hOverlap = value
        case .vertical:
            vOverlap = value
        }
    }
    
    func setComponentsLock(for axis: Axis, to value: Bool) {
        switch axis {
        case .horizontal:
            columnsLock = value
        case .vertical:
            rowsLock = value
        }
    }
    
    func setFOVLock(for axis: Axis, to value: Bool) {
        switch axis {
        case .horizontal:
            hFOVLock = value
        case .vertical:
            vFOVLock = value
        }
    }
    
    func setOverlapLock(for axis: Axis, to value: Bool) {
        switch axis {
        case .horizontal:
            hOverlapLock = value
        case .vertical:
            vOverlapLock = value
        }
    }
    
    func getIdentifier() -> String? {
        return identifier
    }
    
    func getValueSet(for axis: Axis) -> PanoValueSet {
        switch axis {
        case .horizontal:
            return PanoValueSet(components: columns, fov: hFOV, overlap: hOverlap)
        case .vertical:
            return PanoValueSet(components: rows, fov: vFOV, overlap: vOverlap)
        }
    }
    
    func getLockSet(for axis: Axis) -> PanoLockSet {
        switch axis {
        case .horizontal:
            return PanoLockSet(componentsLock: columnsLock, fovLock: hFOVLock, overlapLock: hOverlapLock)
        case .vertical:
            return PanoLockSet(componentsLock: rowsLock, fovLock: vFOVLock, overlapLock: vOverlapLock)
        }
    }
    
    func identifierIsUnique(identifier: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Check that identifier is unique
        
        let filterPred = NSPredicate(format: "\(core_identifierKey) == %@", identifier)
        let fetchRequest: NSFetchRequest<PanoConfig> = PanoConfig.fetchRequest()
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
            fatalError("Error fetching PanoConfig objects")
        }
        
        return true
    }
    
    func savePanoConfig() -> Bool {
        guard let identifier = self.identifier else {
            fatalError("Cannot save a pano config with an empty identifier")
        }
        
        let panoConfig: PanoConfig
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        // Check that identifier is unique
        
        if (!identifierIsUnique(identifier: identifier)) {
            return false
        }
        
        // Rewrite this editor's config, or create a new one
        
        if (self.config != nil) {
            panoConfig = self.config!
        } else {
            panoConfig = PanoConfig(context: context)
        }

        panoConfig.setValue(identifier, forKey: core_identifierKey)

        panoConfig.setValue(rowsLock, forKey: core_rowsLockKey)
        panoConfig.setValue(columnsLock, forKey: core_columnsLockKey)
        panoConfig.setValue(hFOVLock, forKey: core_hFOVLockKey)
        panoConfig.setValue(vFOVLock, forKey: core_vFOVLockKey)
        panoConfig.setValue(hOverlapLock, forKey: core_hOverlapLockKey)
        panoConfig.setValue(vOverlapLock, forKey: core_vOverlapLockKey)

        panoConfig.setValue(columnsLock ? columns : nil, forKey: core_columnsKey)
        panoConfig.setValue(hFOVLock ? hFOV : nil, forKey: core_hFOVKey)
        panoConfig.setValue(hOverlapLock ? hOverlap : nil, forKey: core_hOverlapKey)
        
        panoConfig.setValue(rowsLock ? rows : nil, forKey: core_rowsKey)
        panoConfig.setValue(vFOVLock ? vFOV : nil, forKey: core_vFOVKey)
        panoConfig.setValue(vOverlapLock ? vOverlap : nil, forKey: core_vOverlapKey)
        
        appDelegate.saveContext()
        return true
    }
}

