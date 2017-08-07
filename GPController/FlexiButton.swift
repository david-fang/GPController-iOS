//
//  FlexiButton.swift
//  GPController
//
//  Created by David Fang on 6/7/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class FlexiButton: UIButton {

    @IBInspectable var borderWidth: CGFloat = 1.5
    @IBInspectable var borderColor: UIColor? = UIColor.black
    @IBInspectable var cornerRadius: CGFloat = 30
    @IBInspectable var isCircular: Bool = false

    fileprivate var cachedBorderColor: UIColor?
    fileprivate var cachedBackgroundColor: UIColor?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        self.cachedBorderColor = self.borderColor
        self.cachedBackgroundColor = self.backgroundColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = isCircular ? 0.5 * self.bounds.size.width : cornerRadius
        self.clipsToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
    }
    
    override var isHighlighted: Bool {
        didSet {
            if self.cachedBackgroundColor != UIColor.clear {
                let background = self.isHighlighted ? self.cachedBackgroundColor?.withAlphaComponent(0.7) : self.cachedBackgroundColor
                let border = self.isHighlighted ? self.cachedBorderColor?.withAlphaComponent(0.7) : self.cachedBorderColor

                UIView.animate(withDuration: 0.3, animations: { _ in
                    self.backgroundColor = background
                    self.borderColor = border
                })
            }
        }
    }

    func activate(_ on: Bool) {
        if (on) {
            cachedBackgroundColor = self.backgroundColor
            self.backgroundColor = UIColor(red: 234/255, green: 203/255, blue: 137/255, alpha: 1.0)
        } else {
            self.backgroundColor = cachedBackgroundColor
        }
    }
}
