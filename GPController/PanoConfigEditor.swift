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
    
    enum Axis {
        case horizontal
        case vertical
    }
    
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

    fileprivate let cam_HFOV:       Int
    fileprivate let cam_VFOV:       Int
    
    fileprivate var identifier:     String

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
    
    // init(identifier: String, delegate: PanoConfigEditorDelegate) {
        // Find the PanoConfig with this unique identifier
        // and load the data into this editor model

        // self.delegate = delegate
    // }
    
    init(cam_HFOV: Int, cam_VFOV: Int) {
        self.cam_HFOV = cam_HFOV
        self.cam_VFOV = cam_VFOV
        
        let numRows = GPCalculate.numComponents(panoFOV: DEFAULT_PANO_HFOV, lensFOV: cam_HFOV, overlap: DEFAULT_PANO_OVERLAP)
        let numColumns = GPCalculate.numComponents(panoFOV: DEFAULT_PANO_VFOV, lensFOV: cam_VFOV, overlap: DEFAULT_PANO_OVERLAP)
        
        identifier = "unidentified"

        rows = numRows
        hFOV = DEFAULT_PANO_HFOV
        hOverlap = DEFAULT_PANO_OVERLAP
        rowsLock = true
        hFOVLock = true
        hOverlapLock = false
        
        columns = numColumns
        vFOV = DEFAULT_PANO_VFOV
        vOverlap = DEFAULT_PANO_OVERLAP
        columnsLock = true
        vFOVLock = true
        vOverlapLock = false
    }

    func setIdentifier(to id: String) {
        identifier = id
    }
    
    func setComponents(for axis: Axis, to value: Int) {
        switch axis {
        case .horizontal:
            rows = value
        case .vertical:
            columns = value
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
            rowsLock = value
        case .vertical:
            columnsLock = value
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
    
    func getValueSet(for axis: Axis) -> PanoValueSet {
        switch axis {
        case .horizontal:
            return PanoValueSet(components: rows, fov: hFOV, overlap: hOverlap)
        default:
            return PanoValueSet(components: columns, fov: vFOV, overlap: vOverlap)
        }
    }
    
    func getLockSet(for axis: Axis) -> PanoLockSet {
        switch axis {
        case .horizontal:
            return PanoLockSet(componentsLock: rowsLock, fovLock: hFOVLock, overlapLock: hOverlapLock)
        default:
            return PanoLockSet(componentsLock: columnsLock, fovLock: vFOVLock, overlapLock: vOverlapLock)
        }
    }
    
    func savePanoConfig() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let filterPred = NSPredicate(format: "\(pano_IdentifierKey) == %@", self.identifier)
        let fetchRequest: NSFetchRequest<PanoConfig> = PanoConfig.fetchRequest()
        fetchRequest.predicate = filterPred
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            let panoConfig: PanoConfig
            
            if (fetchResults.count < 1) {
                panoConfig = PanoConfig(context: context)
            } else {
                panoConfig = fetchResults[0]
                
                
                print("Found one!")
            }

            panoConfig.setValue(identifier, forKey: pano_IdentifierKey)
            panoConfig.setValue(rows, forKey: pano_RowsKey)
            panoConfig.setValue(hFOV, forKey: pano_hFOVKey)
            panoConfig.setValue(hOverlap, forKey: pano_hOverlapKey)
            panoConfig.setValue(columns, forKey: pano_ColumnsKey)
            panoConfig.setValue(vFOV, forKey: pano_vFOVKey)
            panoConfig.setValue(vOverlap, forKey: pano_vOverlapKey)
            
            panoConfig.setValue(rowsLock, forKey: pano_RowsLockKey)
            panoConfig.setValue(columnsLock, forKey: pano_ColumnsLockKey)
            panoConfig.setValue(hFOVLock, forKey: pano_hFOVLockKey)
            panoConfig.setValue(vFOVLock, forKey: pano_vFOVLockKey)
            panoConfig.setValue(hOverlapLock, forKey: pano_hOverlapLockKey)
            panoConfig.setValue(vFOVLock, forKey: pano_vOverlapLockKey)
            
            appDelegate.saveContext()
            
            print("Saved config!")
            
        } catch {
            print("Error fetching PanoConfig object")
            return
        }
    }
}







