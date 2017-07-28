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

    let positions: [Corner] = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    let orders: [Order] = [.rows, .columns]
    let patterns: [Pattern] = [.unidirectional, .snake]
    
    var hValueSet: PanoConfigEditor.PanoValueSet!
    var vValueSet: PanoConfigEditor.PanoValueSet!

    var startPositionIndex: Int = 0
    var orderIndex: Int = 0
    var patternIndex: Int = 0

    var pickerTag: Int = 0 {
        didSet {
            pickerView.reloadPickerView()
            
            switch pickerTag {
            case 0:
                pickerView.selectRow(startPositionIndex, animated: false)
            case 1:
                pickerView.selectRow(orderIndex, animated: false)
            case 2:
                pickerView.selectRow(patternIndex, animated: false)
            default:
                break
            }
            
            displayPopup()
        }
    }

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
            return positions.count
        case 1:
            return orders.count
        case 2:
            return patterns.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        switch pickerTag {
        case 0:
            return positions[row].asString
        case 1:
            return orders[row].asString
        case 2:
            return patterns[row].asString
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
            startPositionIndex = row
            startPositionBtn.setTitle(positions[row].asString, for: .normal)
        case 1:
            orderIndex = row
            orderBtn.setTitle(orders[row].asString, for: .normal)
        case 2:
            patternIndex = row
            patternBtn.setTitle(patterns[row].asString, for: .normal)
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

                        let tiltAngle = GPCalculate.angle(panoFOV: vValueSet.fov, numComponents: vValueSet.components)
                        let panAngle = GPCalculate.angle(panoFOV: hValueSet.fov, numComponents: hValueSet.components)

                        dest.panoManager = PanoManager(with: manager, columns: hValueSet.components, rows: vValueSet.components, tiltAngle: tiltAngle, panAngle: panAngle, start: positions[startPositionIndex], order: orders[orderIndex], pattern: patterns[patternIndex])
                    }
                }
            }
        }
    }
    
    @IBAction func openPicker(_ sender: UIButton) {
        pickerTag = sender.tag
    }
}
