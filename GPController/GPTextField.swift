//
//  PaddedTextField.swift
//  GPController
//
//  Created by David Fang on 7/10/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class GPTextField: UITextField {

    @IBInspectable var topPadding: CGFloat = 0
    @IBInspectable var leftPadding: CGFloat = 5
    @IBInspectable var bottomPadding: CGFloat = 0
    @IBInspectable var rightPadding: CGFloat = 5
    
    @IBInspectable var drawToTint: Bool = false
    
    var tintedClearImage: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if (drawToTint) {
            setupTintColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if (drawToTint) {
            setupTintColor()
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding);
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding);
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func setupTintColor() {
        clearButtonMode = UITextFieldViewMode.whileEditing
        borderStyle = UITextBorderStyle.roundedRect
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        layer.borderColor = tintColor.cgColor
        layer.borderWidth = 1.5
        backgroundColor = UIColor.clear
        textColor = tintColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tintClearImage()
    }
    
    private func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let uiImage = button.image(for: .highlighted) {
                    if tintedClearImage == nil {
                        tintedClearImage = tintImage(image: uiImage, color: tintColor)
                    }
                    button.setImage(tintedClearImage, for: .normal)
                    button.setImage(tintedClearImage, for: .highlighted)
                }
            }
        }
    }
}


func tintImage(image: UIImage, color: UIColor) -> UIImage? {
    let size = image.size
    
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.draw(at: CGPoint.zero, blendMode: CGBlendMode.normal, alpha: 1.0)
    
    context?.setFillColor(color.cgColor)
    context?.setBlendMode(CGBlendMode.sourceIn)
    context?.setAlpha(1.0)
    
    let rect = CGRect(x: CGPoint.zero.x, y: CGPoint.zero.y, width: image.size.width, height: image.size.height)

    UIGraphicsGetCurrentContext()?.fill(rect)
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tintedImage
}
