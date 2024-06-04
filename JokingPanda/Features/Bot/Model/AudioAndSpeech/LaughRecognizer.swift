//
//  LaughRecognizer.swift
//  JokingPanda
//
/*
 Uses speech recognition to 'hear' what a user says and updates `phraseHeard` as a user says something.
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
    private var loudness: Float = 0.0
    private var laughRecordingTimer:Timer?
    
    internal func listen() {
        startLaughRecognizer()
        stopLaughRecognizer(after: .seconds(3))
    }
    
    internal func stop() {
        self.laughRecordingTimer?.invalidate()
        self.laughRecordingTimer = nil
        self.audioRecorder?.stop()
    }
    
    private func startLaughRecognizer() {
        do {
            self.loudness = 0
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            if let documentsDirectory = Tool.getDocumentsDirectory() {
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
                self.audioRecorder?.record()
                self.isRecording = true
            }
            
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate() // Stop the timer if self is deallocated
                    return
                }
                
                laughRecordingTimer = timer
                
                self.audioRecorder?.updateMeters()
                if let recorder = self.audioRecorder {
                    let averagePower = recorder.averagePower(forChannel: 0)
                    if averagePower > -70 {
                        var weightedloudness = ((averagePower + 70) / 60) * 5
                        if weightedloudness < 1 {
                            weightedloudness = floor(weightedloudness)
                        }
                        else if weightedloudness > 4.4 {
                            weightedloudness = ceil(weightedloudness)
                        }
                        else {
                            weightedloudness = round(weightedloudness)
                        }
                        
                        if weightedloudness > self.loudness {
                            self.loudness = weightedloudness
                        }
                    }
                    else {
                        self.loudness = 0
                    }
                    self.delegate?.isRecognizing(loudness: self.loudness)
                }
            }
        } catch {
            debugPrint("Error recording audio: \(error.localizedDescription)")
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
        delegate?.didRecognize(loudness: self.loudness)
    }
}
