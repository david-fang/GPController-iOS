//
//  ImageFooter.swift
//  GPController
//
//  Created by David Fang on 8/8/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class ImageFooter: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath()
        let shapeLayer = CAShapeLayer()

        path.move(to: CGPoint(x: bounds.size.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.size.height))
        path.addLine(to: CGPoint(x: bounds.size.width, y: 0))
        path.close()

        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor

        self.layer.mask = shapeLayer
    }
}
