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
        loadRecordUIFor(isRecording: false, PPConstants.recordStatusDefault)
    }
    
    // MARK: - Actions
    // Action on tapping Mic Button
    @IBAction func recordTapped(_ sender: Any) {
        // Call Audio Manager with Recording On status
        PPAudioManager.sharedManager.setAudioManagerTo(recordingStatus: .RecordingOn) { (success, error) in
            // Check if status is true , if yes load recording on UI
            if success {
                // Recording started successfully load UI
                self.loadRecordUIFor(isRecording: true)
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
                self.loadRecordUIFor(isRecording: false, PPConstants.recordStatusRerecord)
                // Navigate to Effects View Controller on Stop
                self.showEffectsViewController()
            }
            else {
              self.fallback() // Error Saving Audio File Display Error UI
            }
        }
    }

    // MARK: - UI Methods
    // Load UI based on recording state
    func loadRecordUIFor(isRecording: Bool,_ statusMessage: String? = nil) {
        // Check if recording is on
        if isRecording {
            recordButton.isEnabled = false
            statusLabel.text = PPConstants.recordStatusStarted
            stopRecordButton.isHidden = false
            return
        }
        recordButton.isEnabled = true
        statusLabel.text = statusMessage ?? PPConstants.recordStatusFallback
        stopRecordButton.isHidden = true
    }
    
    // UI when any Error Happens
    func fallback() {
        loadRecordUIFor(isRecording: false, PPConstants.recordStatusFallback)
    }
    
    // MARK: - Navigation Methods
    func showEffectsViewController() {
        // Show Effects View Controller
        performSegue(withIdentifier: PPConstants.effectsViewController , sender: self)
    }
}

