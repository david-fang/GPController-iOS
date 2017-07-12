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
