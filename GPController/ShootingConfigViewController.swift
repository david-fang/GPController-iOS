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
    
    let positionTitles = ["Top left", "Top right", "Bottom left", "Bottom right"]
    let orderTitles = ["Rows", "Columns"]
    let patternTitles = ["Unidirectional", "Snake"]
    
    var hValueSet: PanoConfigEditor.PanoValueSet!
    var vValueSet: PanoConfigEditor.PanoValueSet!
    
    var pickerTag: Int = 0 {
        didSet {
            pickerView.reloadPickerView()
            
            switch pickerTag {
            case 0:
                pickerView.selectRow(pickPositionIdx, animated: false)
            case 1:
                pickerView.selectRow(pickOrderIdx, animated: false)
            case 2:
                pickerView.selectRow(pickPatternIdx, animated: false)
            default:
                break
            }
            
            displayPopup()
        }
    }

    var pickPositionIdx: Int = 0
    var pickOrderIdx: Int = 0
    var pickPatternIdx: Int = 0
    
    // MARK: - Shooting Config View
    
    @IBOutlet weak var startPositionBtn: UIButton!
    @IBOutlet weak var orderBtn: UIButton!
    @IBOutlet weak var patternBtn: UIButton!

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
    
    func pickerView(_ pickerView: PickerView, didSelectRow row: Int, index: Int) {
        switch pickerTag {
        case 0:
            pickPositionIdx = row
            startPositionBtn.setTitle(positionTitles[row], for: .normal)
        case 1:
            pickOrderIdx = row
            orderBtn.setTitle(orderTitles[row], for: .normal)
        case 2:
            pickPatternIdx = row
            patternBtn.setTitle(patternTitles[row], for: .normal)
        default:
            break
        }
    }
    
    // MARK: - Picker View Display
    
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

    @IBAction func toReferenceSetting(_ sender: UIButton) {
        performSegue(withIdentifier: "toReferencePoint", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toReferencePoint") {
            if let dest = segue.destination as? SetReferenceViewController {
                if let nc = self.navigationController as? GPNavigationController {
                    if let manager = nc.gpBTManager {
                        dest.gpBTManager = manager
                        
                        let verticalAngle = GPCalculate.angle(panoFOV: vValueSet.fov, numComponents: vValueSet.components)
                        let horizontalAngle = GPCalculate.angle(panoFOV: hValueSet.fov, numComponents: hValueSet.components)

                        dest.panoManager = PanoManager(with: manager, columns: hValueSet.components, rows: vValueSet.components, vAngle: verticalAngle, hAngle: horizontalAngle)
                    }
                }
            }
        }
    }
    
    @IBAction func openPicker(_ sender: UIButton) {
        pickerTag = sender.tag
    }
}
