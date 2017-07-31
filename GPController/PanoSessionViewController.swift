//
//  PanoSessionViewController.swift
//  GPController
//
//  Created by David Fang on 7/28/17.
//  Copyright © 2017 CyArk. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class PanoSessionViewController: UIViewController, PanoramaListenerDelegate {

    @IBOutlet var timerSettingsPopup: UIView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var updateTextfield: UITextField!

    @IBOutlet weak var progressIndicator: KDCircularProgress!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var panoControlButton: UIButton!

    let blurEffect = UIBlurEffect(style: .light)
    var blurEffectView: UIVisualEffectView?
    
    var panoManager: PanoManager?
    var finishFanfarePlayer: AVAudioPlayer!
    
    var activeEditTag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurEffectView = UIVisualEffectView()
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let path = Bundle.main.path(forResource: "fox_fanfare", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)

        do {
            finishFanfarePlayer = try AVAudioPlayer(contentsOf: url)
            finishFanfarePlayer.prepareToPlay()
        } catch {
            print("Couldn't create audio player")
        }
        
        guard let manager = panoManager else {
            let alert = UIAlertController(title: "Unable to create panorama manager", message: "The panorama manager for the GigaPan could not be created. Make sure your Bluetooth is enabled and that your device is connected to the GigaPan.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            return
        }
        
        manager.delegate = self
        progressLabel.text = "# 0 of \(manager.grid.totalComponents)"
        
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startPanorama(_ sender: UIButton) {
        guard let manager = panoManager else {
            return
        }

        if (manager.getPanoState() == .stopped) {
            manager.start()
            sender.setTitle("PAUSE", for: .normal)
        } else if (manager.getPanoState() == .running) {
            manager.pause()
            sender.setTitle("RESUME", for: .normal)
        } else {
            manager.resume()
            sender.setTitle("PAUSE", for: .normal)
        }
    }
    
    func nextCycleWillBegin() {
        guard let manager = panoManager else {
            return
        }
        
        DispatchQueue.main.async {
            let cycleNum = manager.getCycleNum()
            let total = manager.grid.totalComponents
            let percentageComplete: Double = Double(cycleNum) / Double(total)
            
            self.progressLabel.text = "# \(cycleNum) of \(total)"
            self.progressIndicator.animate(toAngle: 360 * percentageComplete, duration: 0.3, completion: nil)
        }
    }

    func panoramaDidFinish() {
        let alert = UIAlertController(title: "Panorama complete", message: "Your panorama has been completed!", preferredStyle: .alert)
        
        DispatchQueue.main.async {
            self.finishFanfarePlayer.play()
            self.panoControlButton.setTitle("START", for: .normal)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))

            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Navigation

    @IBAction func back(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editSettings(_ sender: UIButton) {
        activeEditTag = sender.tag
        
        if let blurView = blurEffectView {
            view.addSubview(blurView)
        }
        
        view.addSubview(timerSettingsPopup)
        timerSettingsPopup.bounds = view.bounds
        timerSettingsPopup.center = view.center
        timerSettingsPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        timerSettingsPopup.alpha = 0
        
        switch activeEditTag {
        case 0:
            updateButton.setTitle("UPDATE PRE-TRIGGER DELAY", for: .normal)
            updateTextfield.text = String(panoManager?.preTriggerDelay ?? 0)
        case 1:
            updateButton.setTitle("UPDATE BULB TIME", for: .normal)
            updateTextfield.text = String(panoManager?.bulb ?? 0)
        case 2:
            updateButton.setTitle("UPDATE POST-TRIGGER DELAY", for: .normal)
            updateTextfield.text = String(panoManager?.postTriggerDelay ?? 0)
        default:
            break
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurEffectView?.effect = self.blurEffect
            self.timerSettingsPopup.alpha = 1
            self.timerSettingsPopup.transform = .identity
        })
    }
    
    @IBAction func closePopup(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.timerSettingsPopup.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.timerSettingsPopup.alpha = 0
            self.blurEffectView?.effect = nil
        }, completion: { (success: Bool) in
            self.timerSettingsPopup.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
        })
    }
    
    @IBAction func saveSettings(_ sender: UIButton) {
        let text = updateTextfield.text ?? ""
        let value = Double(text) ?? 0
        
        switch activeEditTag {
        case 0:
            panoManager?.preTriggerDelay = value
        case 1:
            panoManager?.bulb = value
        case 2:
            panoManager?.postTriggerDelay = value
        default:
            break
        }
        
        closePopup(sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
