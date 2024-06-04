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
    func isRecognizing(loudness: Float)
    func didRecognize(loudness: Float)
}

class LaughRecognizer: NSObject {
    internal weak var delegate: LaughRecognizerDelegate?
    
    private var audioRecorder: AVAudioRecorder?
    private var isRecording = false
    private var weightedLoudness: Float = 0.0
    private var laughRecordingTimer:Timer?
    
    internal func start() {
        self.weightedLoudness = 0
        startLaughRecognizer()
        stopLaughRecognizer(after: .seconds(3))
    }
    
    internal func stop() {
        self.laughRecordingTimer?.invalidate()
        self.laughRecordingTimer = nil
        self.audioRecorder?.stop()
    }
    
    // MARK: - Setup
    
    private func startLaughRecognizer() {
        setUpAudioSession()
        setUpAudioRecorder()
        startAudioRecorder()
        captureLaughter(withTimeInteval: 0.2)
    }
    
    private func setUpAudioSession() {
        do {
            self.weightedLoudness = 0
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            debugPrint("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    
    private func setUpAudioRecorder() {
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
            debugPrint("Error setting up audio recorder: \(error.localizedDescription)")
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
            
            self.delegate?.isRecognizing(loudness: self.weightedLoudness)
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
}

extension LaughRecognizer: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: (any Error)?) {
        // FIXME: - Handle errors
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // FIXME: - Handle errors
        isRecording = false
        delegate?.didRecognize(loudness: self.weightedLoudness)
    }
}
