//
//  GPPanoSelectionCell.swift
//  GPController
//
//  Created by David Fang on 7/7/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class GPPanoSelectionCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var identifierLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none

        cardView.layer.cornerRadius = 4.0
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
