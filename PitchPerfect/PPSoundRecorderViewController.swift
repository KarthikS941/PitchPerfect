//
//  PPSoundRecorderViewController.swift
//  PitchPerfect
//
//  Created by Karthik Sankar on 8/31/17.
//  Copyright © 2017 Karthik Sankar. All rights reserved.
//

import UIKit

class PPSoundRecorderViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Set Default UI when launch
        self.loadRecordStoppedUIWith(PPConstants.recordStatusDefault)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Actions
    // Action on tapping Mic Button
    @IBAction func recordTapped(_ sender: Any) {
        // Call Audio Manager with Recording On status
        PPAudioManager.sharedManager.setAudioManagerTo(recordingStatus: .RecordingOn) { (success, error) in
            // Check if status is true , if yes load recording on UI
            if success {
                self.loadRecordingUI() // Recording started successfully load UI
            }
            else {
                self.fallback() // Error Starting Recording Display Error UI
            }
        }
        
    }
    
    // Action on tapping Stop Recording Button
    @IBAction func stopRecordTapped(_ sender: Any) {
        // Call Audio Manager with Recording Off Status
        PPAudioManager.sharedManager.setAudioManagerTo(recordingStatus: .RecordingOff) { (success, error) in
            if success {
                // Display Re Record UI
                self.loadRecordStoppedUIWith(PPConstants.recordStatusRerecord)
                // Navigate to Effects View Controller on Stop
                self.showEffectsViewController()
            }
            else {
              self.fallback() // Error Saving Audio File Display Error UI
            }
        }
    }

    // MARK: - UI Methods
    // UI when Recording is started
    func loadRecordingUI() {
        self.recordButton.isEnabled = false
        self.statusLabel.text = PPConstants.recordStatusStarted
        self.stopRecordButton.isHidden = false
    }
    
    // UI when recording is finished / Default UI
    func loadRecordStoppedUIWith(_ statusMessage:String) {
        self.recordButton.isEnabled = true
        self.statusLabel.text = statusMessage
        self.stopRecordButton.isHidden = true
    }
    
    // UI when any Error Happens
    func fallback() {
        self.loadRecordStoppedUIWith(PPConstants.recordStatusFallback)
    }
    
    // MARK: - Navigation Methods
    func showEffectsViewController() {
        // Show Effects View Controller
        self.performSegue(withIdentifier: PPConstants.effectsViewController , sender: self)
    }
}

