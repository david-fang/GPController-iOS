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

    static var sandpaperWhite: UIColor {
        return UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    }
    
    static var taupe: UIColor {
        return UIColor(red: 217/255, green: 206/255, blue: 174/255, alpha: 1.0)
    }
    
    static var darkTaupe: UIColor {
        return UIColor(red: 167/255, green: 154/255, blue: 118/255, alpha: 1.0)
    }

    static var goldenBrown: UIColor {
        return UIColor(red: 195/255, green: 179/255, blue: 146/255, alpha: 1.0)
    }
    
    static var cyarkGold: UIColor {
        return UIColor(red: 255/255, green: 206/255, blue: 0/255, alpha: 1.0)
    }
    
    static var cyarkBlack: UIColor {
        return UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0)
    }
    
    static func getWithRGB(_ red: Double, green: Double, blue: Double, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: alpha)
    }
}

