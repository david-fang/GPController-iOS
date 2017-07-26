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

    fileprivate var cachedBackgroundColor: UIColor?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
    }
    
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
    
    func activate(_ on: Bool) {
        if (on) {
            cachedBackgroundColor = self.backgroundColor
            self.backgroundColor = UIColor(red: 234/255, green: 203/255, blue: 137/255, alpha: 1.0)
        } else {
            self.backgroundColor = cachedBackgroundColor
        }
    }
}
