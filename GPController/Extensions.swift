//
//  FlashLayer.swift
//  GPController
//
//  Created by David Fang on 6/13/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

extension CAAnimation {
    
    /** Adds a flashing animation */
    static func addFlashLayer(to layer: CALayer) {
        let flash: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        let easeOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        flash.fromValue = 1.0
        flash.toValue = 0.7
        flash.duration = 1.5
        flash.autoreverses = true
        flash.repeatCount = Float.infinity
        flash.timingFunction = easeOut
        
        layer.add(flash, forKey: "flashAnimation")
    }
}
