//
//  ShootingConfigViewController.swift
//  GPController
//
//  Created by David Fang on 7/20/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit

class ShootingConfigViewController: UIViewController, PickerViewDelegate, PickerViewDataSource {

    // MARK: - Picker Popup
    
    @IBOutlet var pickerPopup: UIView!
    @IBOutlet weak var pickerView: PickerView!

    let blurEffect = UIBlurEffect(style: .light)
    var blurEffectView: UIVisualEffectView?
    
    var pickerTag: Int = 0 {
        didSet {
            pickerView.reloadPickerView()
            pickerView.selectRow(0, animated: false)
            displayPopup()
        }
    }
    
    let positionTitles = ["Top left", "Top right", "Bottom left", "Bottom right"]
    let orderTitles = ["Rows", "Columns"]
    let patternTitles = ["Unidirectional", "Snake"]
    
    // MARK: - Shooting Config View

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectionStyle = .defaultIndicator
        
        blurEffectView = UIVisualEffectView()
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        switch pickerTag {
        case 0:
            return positionTitles.count
        case 1:
            return orderTitles.count
        case 2:
            return patternTitles.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        switch pickerTag {
        case 0:
            return positionTitles[row]
        case 1:
            return orderTitles[row]
        case 2:
            return patternTitles[row]
        default:
            return ""
        }
    }
    
    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return pickerView.frame.height / 3
    }
    
    func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        label.textAlignment = .center
        
        if highlighted {
            label.font = UIFont.systemFont(ofSize: 23.0)
            label.textColor = UIColor(red: 209/255, green: 181/255, blue: 121/255, alpha: 1.0)
        } else {
            label.font = UIFont.systemFont(ofSize: 20.0)
            label.textColor = UIColor.lightGray.withAlphaComponent(0.7)
        }
    }
    
    func displayPopup() {
        if let blurView = blurEffectView {
            view.addSubview(blurView)
        }

        view.addSubview(pickerPopup)
        pickerPopup.center = view.center
        pickerPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        pickerPopup.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            self.blurEffectView?.effect = self.blurEffect
            self.pickerPopup.alpha = 1
            self.pickerPopup.transform = .identity
        })
    }
    
    @IBAction func dismissPopup(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.pickerPopup.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.pickerPopup.alpha = 0
            self.blurEffectView?.effect = nil
        }, completion: { (success: Bool) in
            self.pickerPopup.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
        })
    }
    
    // MARK: - Navigation

     @IBAction func back(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
     }
    
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func openPicker(_ sender: UIButton) {
        pickerTag = sender.tag
    }
}
