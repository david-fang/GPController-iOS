/**
 *
 * DesignUtils.swift
 *
 * Copyright (c) 2017, CyArk
 * All rights reserved.
 *
 * Created by David Fang
 *
 * Assortment of utility functions for generating animations or
 * creating customized views.
 *
 */

import UIKit

extension CALayer {

    /** Adds a flashing animation */
    func addFlashLayer() {
        let flash: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        let easeIn = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)

        flash.fromValue = 0.0
        flash.toValue = 1.0
        flash.duration = 1.0
        flash.autoreverses = true
        flash.repeatCount = Float.infinity
        flash.timingFunction = easeIn

        self.add(flash, forKey: "flashAnimation")
    }
}

extension UIView {
    
    /** Adds a drop shadow to the view */
    func addDropShadow(color: UIColor, shadowOffset: CGSize, shadowOpacity: Float, shadowRadius: CGFloat) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
    }
    
    /**
     * Adds a subview above the view with a blur effect background and
     * a "popup" animation.
     *
     * - Parameter subview: The subview to pop up
     * - Parameter blurEffectView: An instance of the blur view background
     */
    func popupSubview(subview: UIView, blurEffectView: UIVisualEffectView) {
        let blurEffect = UIBlurEffect(style: .light)
        
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        DispatchQueue.main.async {
            self.addSubview(blurEffectView)
            
            self.addSubview(subview)
            subview.frame = self.bounds
            subview.bounds = self.bounds
            subview.center = self.center
            subview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            subview.alpha = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                blurEffectView.effect = blurEffect
                subview.alpha = 1
                subview.transform = .identity
            })
        }
    }
    
    
    /**
     * Removes a subview above and its blur effect background with a
     * "reverse popup" animation.
     *
     * - Parameter subview: The subview to remove
     * - Parameter blurEffectView: A reference to the popup's blur background
     * - Parameter completion: Completion handler for this animation
     */
    func closePopup(subview: UIView, blurEffectView: UIVisualEffectView, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.4, animations: {
            subview.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            subview.alpha = 0
            blurEffectView.effect = nil
        }, completion: { (success: Bool) in
            subview.removeFromSuperview()
            blurEffectView.removeFromSuperview()
            completion?()
        })
    }
}
