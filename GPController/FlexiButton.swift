//
//  RoundedButton.swift
//  GPController
//
//  Created by David Fang on 6/7/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class FlexiButton: UIButton {

    @IBInspectable var borderWidth: CGFloat = 1.5
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var cornerRadius: CGFloat = 30
    @IBInspectable var isCircular: Bool = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = isCircular ? 0.5 * self.bounds.size.width : cornerRadius
        self.clipsToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, animations: { _ in
                self.alpha = self.isHighlighted ? 0.65 : 1.0
            })
        }
    }
}
