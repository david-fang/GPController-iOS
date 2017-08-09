//
//  ScannedDeviceCell.swift
//  GPController
//
//  Created by David Fang on 8/3/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class ScannedDeviceCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var deviceIdentifier: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
        cardView.clipsToBounds = false
        cardView.addDropShadow(color: UIColor.darkGray, shadowOffset: CGSize(width: 0, height: 7), shadowOpacity: 0.2, shadowRadius: 3.0)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if (!animated) {
            cardView.alpha = highlighted ? 0.65 : 1
        } else {
            UIView.animate(withDuration: 0.75, animations: {
                self.cardView.alpha = highlighted ? 0.65 : 1
            })
        }
    }
}
