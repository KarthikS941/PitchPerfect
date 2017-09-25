//
//  PPAudioManager.swift
//  PitchPerfect
//
//  Created by Karthik Sankar on 9/1/17.
//  Copyright © 2017 Karthik Sankar. All rights reserved.
//
// PPAudio Manager is a Singleton used to manage Audio Effects , Recording and Playback
import Foundation
import AVFoundation

// Recoding Error
enum PPAudioError:Error {
    case RecordingError     // Recording Error
    case PlaybackError      // Playback Error
    case AudioEngineError   // Audio Engine Error
    case PermissionError    // Audio Permission Error
}

// Audio Manager State
enum PPAudioManagerState {
    case RecordingOn        // Recording is On
    case RecordingOff       // Recording is Off
}

// Audo Effects List
enum PPAudioPlayEffect:Int {
    case snailEffect = 1        // Slow
    case rabitEffect = 2        // Fast
    case darthvaderEffect = 3   // DarthVader
    case chipmunkEffect = 4     // ChipMunk
    case echoEffect = 5         // Echo
    case reverbEffect = 6       // Reverb
}

class PPAudioManager : NSObject {
    
    // Properties
    var currentTrackURL:URL?
    
    // AVAudio Foundation Variables
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioFile:AVAudioFile!
    
    // Create a Singleton Audio Manager
    static let sharedManager = PPAudioManager()
    
    // Recording Status
    var recordingStatus:PPAudioManagerState = PPAudioManagerState.RecordingOff
    
    // Override Init Method
    private override init() {
        recordingSession = AVAudioSession.sharedInstance()
    }
    

    // Callbacks / Completion Handlers
    typealias recodingCompletionHandler = (_ success:Bool,
        _ recordingError:PPAudioError?) -> Void
    
    // Start Recording
    func setAudioManagerTo(recordingStatus:PPAudioManagerState,
                           completionHandler:@escaping recodingCompletionHandler) {
        // Check for State passed 
        switch recordingStatus {
        case PPAudioManagerState.RecordingOn:
            do {
                // Check if Audio Engine was Configured Successfully
                if try self.recordAudio() {
                    completionHandler(true,nil)
                }
            } catch {
                completionHandler(false,PPAudioError.AudioEngineError)
            }
            completionHandler(true, nil)
        case PPAudioManagerState.RecordingOff:
            audioRecorder.stop()
            audioRecorder = nil
            self.setupAudio()
            completionHandler(true,nil)
        }
    }
    
}

// MARK: - Utility Methods
extension PPAudioManager {
    // Get Documents Directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // Get Recording Permission 
    func recordAudio() throws -> Bool {
        if self.getRecordingPermission() {
            // Permission Granted
            do {
                if try self.setupAudioRecorder() {
                    return true
                }
                throw PPAudioError.AudioEngineError
            } catch {
              throw PPAudioError.AudioEngineError
            }
        }
        throw PPAudioError.PermissionError
    }
    
    // Get Mic Access Permission from iOS
    func getRecordingPermission() -> Bool {
        var permissionGranted = false
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                if allowed {
                   permissionGranted = true
                } else {
                    permissionGranted = false
                }
            }
            return permissionGranted
        } catch {
            return false
        }
    }
    
    // Setup Audio Engine
    func setupAudioRecorder() throws -> Bool {
        // Track URL
        self.currentTrackURL = self.getDocumentsDirectory().appendingPathComponent("pitchperfect.m4a")
        // Settings
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        // Setup Audio Recorder
        do {
            audioRecorder = try AVAudioRecorder(url: self.currentTrackURL!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            return true
        } catch {
            throw PPAudioError.AudioEngineError
        }
    }
    
    // Play Audio
    func playAudioIn(effect:PPAudioPlayEffect) {

        switch effect {
        case .snailEffect:
            playAudioWith(rate: PPConstants.snailEffectConstant)
        case .rabitEffect:
            playAudioWith(rate: PPConstants.rabitEffectConstant)
        case .chipmunkEffect:
            playAudioWith(pitch: PPConstants.chipmunkEffectConstant)
        case .darthvaderEffect:
            playAudioWith(pitch: PPConstants.darthvaderEffectConstant)
        case .echoEffect:
            playAudioWith(echo: true)
        case .reverbEffect:
            playAudioWith(reverb: true)
        }
    }
    
    // Setup Audio
    func setupAudio() {
        // initialize (recording) audio file
        do {
            self.audioFile = try AVAudioFile(forReading: self.currentTrackURL! )
        } catch {
            print("Error")
           // showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    // MARK: - Play Audio Effects
    // Function to play audio effects
    fileprivate func playAudioWith(rate:Float? = nil, pitch: Float? = nil,echo:Bool = false, reverb:Bool = false) {
        audioEngine = nil
        audioPlayerNode = nil
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(self.audioFile, at: nil) {
        }
        
        do {
            try audioEngine.start()
        } catch {
            //showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        // play the recording!
        audioPlayerNode.play()
    }
    
    // Connect Audio Nodes
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            self.audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
}

// MARK: - AVAudioDelegate
extension PPAudioManager:AVAudioRecorderDelegate {
    // Called when recording is complete
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    }
}
