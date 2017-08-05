//
//  WatermarkImageView.swift
//  GPController
//
//  Created by David Fang on 8/5/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class WatermarkImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(image: UIImage?) {
        super.init(image: image)
        let overlayImage = #imageLiteral(resourceName: "cyark_gold@150px")
        let overlayImageView = UIImageView(image:overlayImage)

        self.addSubview(overlayImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let overlayImage = #imageLiteral(resourceName: "cyark_gold@150px")
        let overlayImageView = UIImageView(image:overlayImage)
        
        self.addSubview(overlayImageView)
    }
}
