//
//  CustomColors.swift
//  GPController
//
//  Created by David Fang on 6/7/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func metallicBlue() -> UIColor {
        return UIColor(red: 111/255, green: 125/255, blue: 149/255, alpha: 1.0)
    }
    
    static func darkMetallicBlue() -> UIColor {
        return UIColor(red: 53/255, green: 64/255, blue: 82/255, alpha: 1.0)
    }
    
    static func getWithRGB(_ red: Double, green: Double, blue: Double, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: alpha)
    }
}

