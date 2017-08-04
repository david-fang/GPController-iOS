//
//  Utils.swift
//  GPController
//
//  Created by David Fang on 7/12/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit


func debugLog(_ string: String, _ debugIsOn: Bool) {
    if (debugIsOn) {
        print(string)
    }
}

func delay(_ delay: Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

extension UIView {
    func addDropShadow(color: UIColor, shadowOffset: CGSize, shadowOpacity: Float, shadowRadius: CGFloat) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
    }
    
    func popupSubview(subview: UIView, blurEffectView: UIVisualEffectView) {
        let blurEffect = UIBlurEffect(style: .light)

        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        DispatchQueue.main.async {
            self.addSubview(blurEffectView)

            self.addSubview(subview)
            subview.bounds = self.bounds
            subview.center = self.center
            subview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            subview.alpha = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                blurEffectView.effect = blurEffect
                subview.alpha = 1
                subview.transform = .identity
            })
        }
    }
    
    func closePopup(subview: UIView, blurEffectView: UIVisualEffectView, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.4, animations: {
            subview.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            subview.alpha = 0
            blurEffectView.effect = nil
        }, completion: { (success: Bool) in
            subview.removeFromSuperview()
            blurEffectView.removeFromSuperview()
            completion?()
        })
    }

}

extension String {
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

class GPCalculate {

    /**
     *  Computes the number of components required to take a panorama with a
     *  field of view of PANOFOV and an overlap of OVERLAP.
     *
     *  WARNING: The overlap cannot be 100%; otherwise, the effective
     *  field of view of the lens is 0, implying zero components.
     */
    static func numComponents(panoFOV: Int, lensFOV: Int, overlap: Int) -> Int {
        guard panoFOV != 0 && lensFOV != 0 && overlap != 100 else {
            fatalError("Invalid arguments to compute components")
        }

        let olapDecimal = Double(overlap) / 100
        let effectiveFOV = Double(lensFOV) * (1 - olapDecimal)
        let numComponents = Double(panoFOV) / effectiveFOV
        let rounded = numComponents.rounded(.up)
        
        return Int(rounded)
    }
    
    /**
     *  Computes the field of view of the panorama given NUMCOMPONENTS and
     *  an overlap of OVERLAP.
     *
     *  WARNING: The overlap cannot be 100%; otherwise, the effective
     *  field of view of the lens is 0, implying a field of view of zero.
     */
    static func panoFOV(numComponents: Int, lensFOV: Int, overlap: Int) -> Int {
        guard numComponents != 0 && lensFOV != 0 && overlap != 100 else {
            fatalError("Invalid arguments to compute pano field of view")
        }

        let olapDecimal = Double(overlap) / 100
        let effectiveFOV = Double(lensFOV) * (1 - olapDecimal)
        let panoFOV = Double(numComponents) * effectiveFOV
        let rounded = panoFOV.rounded(.down)
        
        return Int(rounded)
    }
    
    /**
     *  Computes the overlap between each photo given NUMCOMPONENTS and
     *  a panorama field of view of PANOFOV.
     *
     *  WARNING: There cannot be 0 components; otherwise, the effective field
     *  of view is zero, implying undefined overlap
     */
    static func overlap(numComponents: Int, panoFOV: Int, lensFOV: Int) -> Int {
        
        guard numComponents != 0 && panoFOV != 0 && lensFOV != 0 else {
            fatalError("Invalid arguments to compute overlap")
        }
        
        let effectiveFOV = Double(panoFOV) / Double(numComponents)
        let olapDecimal = 1 - (effectiveFOV / Double(lensFOV))
        let olap = olapDecimal * 100
        let rounded = olap.rounded(.down)
        
        return Int(rounded)
    }

    /**
     *  Computes the angle (effective field of view) between each picture
     *  given the panorama's total field of view and the number of components.
     *
     *  WARNING: The number of components cannot be 0.
     */
    static func angle(panoFOV: Int, numComponents: Int) -> Int {

        guard numComponents != 0 && panoFOV != 0 else {
            fatalError("Invalid arguments to compute angle")
        }
        
        let angle = Double(panoFOV) / Double(numComponents)
        let rounded = angle.rounded(.down)
        
        return Int(rounded)
    }
}

