//
//  PPConstants.swift
//  PitchPerfect
//
//  Created by Karthik Sankar on 9/1/17.
//  Copyright © 2017 Karthik Sankar. All rights reserved.
//

import Foundation

struct PPConstants {
    
    // Segues
    static let effectsViewController = "showEffectsViewController"
    
    // Recording Strings
    static let recordStatusStarted = "Recording..."
    static let recordStatusDefault = "Tap on Mic to start recording."
    static let recordStatusRerecord = "Tap on Mic to re-record."
    static let recordStatusFallback = "Something went wrong please re-record by tapping on Mic."
    
    // Audio Manager Settings
    static let snailEffectConstant:Float = 0.5
    static let rabitEffectConstant:Float = 1.5
    static let chipmunkEffectConstant:Float = 1000.00
    static let darthvaderEffectConstant:Float = -1000.00
}
