//
//  GPCamSelectionCell.swift
//  GPController
//
//  Created by David Fang on 7/18/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class GPCamSelectionCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var hFOVLabel: UILabel!
    @IBOutlet weak var hRESLabel: UILabel!
    @IBOutlet weak var vFOVLabel: UILabel!
    @IBOutlet weak var vRESLabel: UILabel!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        
        cardView.layer.cornerRadius = 4.0
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
