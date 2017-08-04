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
    @IBOutlet weak var rssiImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none

        cardView.addDropShadow(color: UIColor.darkGray, shadowOffset: CGSize(width: 10.0, height: 10.0), shadowOpacity: 0.2, shadowRadius: 10.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if (!animated) {
            cardView.alpha = selected ? 0.65 : 1
        } else {
            UIView.animate(withDuration: 0.75, animations: {
                self.cardView.alpha = selected ? 0.65 : 1
            })
        }
    }
}
