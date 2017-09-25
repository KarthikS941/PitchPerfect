//
//  PPEffectsViewController.swift
//  PitchPerfect
//
//  Created by Karthik Sankar on 9/3/17.
//  Copyright © 2017 Karthik Sankar. All rights reserved.
//

import UIKit

class PPEffectsViewController: UIViewController {
    
    // Outlets for Button
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var chipmukButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    // Common Button Action for all Effect Buttons
    @IBAction func playbackTapped(_ sender: Any) {
        // Play sound based on Button Tag using Audio Manager
        PPAudioManager.sharedManager.playAudioIn(effect: PPAudioPlayEffect(rawValue: (sender as! UIButton).tag)!)
    }

}
