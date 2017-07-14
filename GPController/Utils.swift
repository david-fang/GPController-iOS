//
//  Utils.swift
//  GPController
//
//  Created by David Fang on 7/12/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

extension UIView {
    
    func addDropShadow(color: UIColor, offset: CGSize, opacity: Float, radius: CGFloat) {   
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
}

class GPCalculate {

    static func numComponents(panoFOV: Double, lensFOV: Double, overlap: Double) -> Double {
        let olapDecimal = overlap / 100
        let effectiveFOV = lensFOV * (1 - olapDecimal)
        let numComponents = panoFOV / effectiveFOV
        
        return numComponents.rounded(.up)
    }
    
    static func panoFOV(numComponents: Double, lensFOV: Double, overlap: Double) -> Double {
        let olapDecimal = overlap / 100
        let effectiveFOV = lensFOV * (1 - olapDecimal)
        let panoFOV = numComponents * effectiveFOV
        
        return panoFOV.rounded(.down)
    }
    
    static func overlap(numComponents: Double, panoFOV: Double, lensFOV: Double) -> Double {
        
        let effectiveFOV = panoFOV / numComponents
        let olapDecimal = 1 - (effectiveFOV / lensFOV)
        let olap = olapDecimal * 100
        
        return olap.rounded(.down)
    }
}

