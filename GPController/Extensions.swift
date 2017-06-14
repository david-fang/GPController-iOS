//
//  FlashLayer.swift
//  GPController
//
//  Created by David Fang on 6/13/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

extension CALayer {

    /** Adds a flashing animation */
    func addFlashLayer() {
        let flash: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        let easeOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)

        flash.fromValue = 1.0
        flash.toValue = 0.675
        flash.duration = 1.3
        flash.autoreverses = true
        flash.repeatCount = Float.infinity
        flash.timingFunction = easeOut

        self.add(flash, forKey: "flashAnimation")
    }
}
