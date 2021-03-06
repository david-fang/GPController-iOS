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
    @IBInspectable var isCoverButton: Bool = false

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

                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundColor = background
                    self.borderColor = border
                })
            }
            
            if isCoverButton {
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundColor = self.isHighlighted ? UIColor.darkGray.withAlphaComponent(0.5) : UIColor.clear
                })
            }
        }
    }

    func activate(_ on: Bool, animated: Bool) {
        self.isUserInteractionEnabled = on
        if (animated) {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = on ? 1.0 : 0.7
            })
        } else {
            self.alpha = on ? 1.0 : 0.7
        }
    }
    
    func cacheBackgroundColor() {
        cachedBackgroundColor = self.backgroundColor
    }
}
