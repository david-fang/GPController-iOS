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
        let easeIn = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)

        flash.fromValue = 0.0
        flash.toValue = 1.0
        flash.duration = 1.0
        flash.autoreverses = true
        flash.repeatCount = Float.infinity
        flash.timingFunction = easeIn

        self.add(flash, forKey: "flashAnimation")
    }
}
