//
//  LaughRecognizer.swift
//  JokingPanda
//
/*
 Sets up an instance of AVAudioRecorder, passing `weightedLoudness` through `isRecognizing()` and `didRecognize()` protocal methods.
 `weightedLoudness` stores an adjusted value for the loudness of volume captured chosen based on manual testing with phones.
 */

import Foundation
import Speech

protocol LaughRecognizerDelegate: AnyObject {
    func laughRecognizerIsRecognizing(loudness: Float)
    func laughRecognizerDidRecognize(loudness: Float)
    func laughRecognizerErrorDidOccur(error: Error)
}

enum LaughRecognizerError: LocalizedError {
    case recorderSetupDidFail
    case sessionSetupDidFail
    case recordingInterupted
    
    var errorDescription: String? {
        switch self {
        case .recorderSetupDidFail:
            return "Could Not Start Audio Recorder"
        case .sessionSetupDidFail:
            return "Could Not Set Up Audio Session"
        case .recordingInterupted:
            return "Laugh Capture Interupted"
        }
    }
}

class LaughRecognizer: NSObject {
    internal weak var delegate: LaughRecognizerDelegate?
    
    private var audioRecorder: AVAudioRecorder?
    private var isRecording = false
    private var weightedLoudness: Float = 0.0
    private var laughRecordingTimer:Timer?
    
    internal func start(for timeInterval: DispatchTimeInterval) {
        if !isRecording {
            do {
                self.weightedLoudness = 0
                try startLaughRecognizer()
                stopLaughRecognizer(after: timeInterval)
            }
            catch {
                delegate?.laughRecognizerErrorDidOccur(error: error)
            }
        }
        else {
            debugPrint("Attempting to start laugh recognizer after already started.")
        }
    }
    
    internal func stop() {
        laughRecordingTimer?.invalidate()
        laughRecordingTimer = nil
        audioRecorder?.stop()
        try? deactivateAudioSession()
    }
    
    // MARK: - Setup
    
    private func startLaughRecognizer() throws {
        try setUpAudioSession()
        try setUpAudioRecorder()
        startAudioRecorder()
        captureLaughter(withTimeInteval: 0.2)
    }
    
    private func setUpAudioSession() throws {
        do {
            self.weightedLoudness = 0
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            throw LaughRecognizerError.sessionSetupDidFail
        }
    }
    
    private func setUpAudioRecorder() throws {
        guard let documentsDirectory = Tool.getDocumentsDirectory() else {
            debugPrint("Error getting documents directory")
            return
        }
        
        do {
            let audioFilename = documentsDirectory.appendingPathComponent("tempLaughterRecording.wav")
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ])
            self.audioRecorder?.delegate = self
            self.audioRecorder?.prepareToRecord()
            self.audioRecorder?.isMeteringEnabled = true
        }
        catch {
            throw LaughRecognizerError.recorderSetupDidFail
        }
    }
    
    // MARK: - Actions
    
    private func startAudioRecorder() {
        guard let audioRecorder = self.audioRecorder else {
            debugPrint("Attempting to start audio recorder before initializing")
            return
        }
        audioRecorder.record()
        self.isRecording = true
    }
    
    private func captureLaughter(withTimeInteval timeInterval: TimeInterval) {
        guard let audioRecorder = self.audioRecorder else { return }
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate() // Stop the timer if self is deallocated
                return
            }
            
            laughRecordingTimer = timer
            let averagePower = audioRecorder.averagePower(forChannel: 0)
            updateWeightedLoudness(audioPower: averagePower)
            audioRecorder.updateMeters()
            
            self.delegate?.laughRecognizerIsRecognizing(loudness: self.weightedLoudness)
        }
    }
    
    private func updateWeightedLoudness(audioPower: Float) {
        if audioPower > -70 {
            var weightedloudness = ((audioPower + 70) / 60) * 5
            if weightedloudness < 1 {
                weightedloudness = floor(weightedloudness)
            }
            else if weightedloudness > 4.4 {
                weightedloudness = ceil(weightedloudness)
            }
            else {
                weightedloudness = round(weightedloudness)
            }
            
            if weightedloudness > self.weightedLoudness {
                self.weightedLoudness = weightedloudness
            }
        }
        else {
            self.weightedLoudness = 0
        }
    }
    
    private func stopLaughRecognizer(after time: DispatchTimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.stop()
        }
    }
    
    private func deactivateAudioSession() throws {
        try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

extension LaughRecognizer: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        
        if flag {
            delegate?.laughRecognizerDidRecognize(loudness: self.weightedLoudness)
        } else {
            delegate?.laughRecognizerErrorDidOccur(error: LaughRecognizerError.recordingInterupted)
        }
    }
}
