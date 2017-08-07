//
//  TriangleView.swift
//  AnimationPlayground
//
//  Created by David Fang on 8/6/17.
//  Copyright © 2017 Fang. All rights reserved.
//

import UIKit

class TriangleView: UIView {

    @IBInspectable var facingDown: Bool = true
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath()
        let shapeLayer = CAShapeLayer()
        
        if (facingDown) {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: bounds.size.width, y: 0))
            path.addLine(to: CGPoint(x: bounds.size.width / 2, y: bounds.size.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.close()
        }
        
        else {
            path.move(to: CGPoint(x: bounds.size.width / 2, y: 0))
            path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
            path.addLine(to: CGPoint(x: 0, y: bounds.size.height))
            path.addLine(to: CGPoint(x: bounds.size.width / 2, y: 0))
            path.close()
        }
        
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.yellow.cgColor
        
        self.layer.mask = shapeLayer
    }
}
