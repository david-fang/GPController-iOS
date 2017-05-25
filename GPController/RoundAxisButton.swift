//
//  RoundButton.swift
//  GPController
//
//  Created by David Fang on 5/25/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

@IBDesignable
class RoundAxisButton: UIButton {
    
    enum Direction {
        case Left, Right, Up, Down
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.5
    @IBInspectable var borderColor: UIColor = UIColor.blue

    var direction: Direction = .Left
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaults()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setDefaults()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
        
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
    private func setDefaults() {
        self.isExclusiveTouch = true
        self.adjustsImageWhenHighlighted = false
    }
}
