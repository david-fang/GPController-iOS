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

extension String {
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
