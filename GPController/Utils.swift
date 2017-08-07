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
            subview.frame = self.bounds
            // subview.bounds = self.bounds
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

    func addHeaderTriangleMask() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width / 2, y: bounds.size.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.cyarkBlack.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        
        self.layer.mask = shapeLayer
    }
    
    func addDiamondMask() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.size.width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height / 2.0))
        path.addLine(to: CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.size.height / 2.0))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        
        layer.mask = shapeLayer
    }
    
    func addHexagonMask() {
        let path = roundedPolygonPath(rect: self.frame, lineWidth: 1, sides: 5, cornerRadius: 0, rotationOffset: CGFloat(M_PI / 6.0))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        
        layer.mask = shapeLayer
    }
}

public func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: NSInteger, cornerRadius: CGFloat, rotationOffset: CGFloat = 0) -> UIBezierPath {
    let path = UIBezierPath()
    let theta: CGFloat = CGFloat(2.0 * M_PI) / CGFloat(sides) // How much to turn at every corner
//    let offset: CGFloat = cornerRadius * tan(theta / 2.0)     // Offset from which to start rounding corners
    let width = min(rect.size.width, rect.size.height)        // Width of the square
    
    let center = CGPoint(x: rect.origin.x + width / 2.0, y: rect.origin.y + width / 2.0)
    
    // Radius of the circle that encircles the polygon
    // Notice that the radius is adjusted for the corners, that way the largest outer
    // dimension of the resulting shape is always exactly the width - linewidth
    let radius = (width - lineWidth + cornerRadius - (cos(theta) * cornerRadius)) / 2.0
    
    // Start drawing at a point, which by default is at the right hand edge
    // but can be offset
    var angle = CGFloat(rotationOffset)
    
    let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))

    path.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))
    
    for _ in 0..<sides {
        angle += theta
        
        let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
        let tip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
        let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
        let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
        
        path.addLine(to: start)
        path.addQuadCurve(to: end, controlPoint: tip)
    }
    
    path.close()
    
    // Move the path to the correct origins
    let bounds = path.bounds
    let transform = CGAffineTransform(translationX: -bounds.origin.x + rect.origin.x + lineWidth / 2.0, y: -bounds.origin.y + rect.origin.y + lineWidth / 2.0)
    path.apply(transform)

    return path
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

