//
//  Ear.swift
//  JokingPanda
//
/*
 Uses speech recognition to 'hear' what a user says and updates `phraseHeard` as a user says something.
 */

import Foundation
import Speech

protocol EarDelegate: AnyObject {
    func isHearing(_ phrase: String?, loudness: Float?)
    func didHear(_ phrase: String?,loudness: Float?)
}

class Ear: NSObject {
    internal weak var delegate: EarDelegate?
    private var phraseHeard: String = ""
    private let speechRecognizer: SpeechRecognizer
    private var isListening = false
    
    private var audioRecorder: AVAudioRecorder?
    private let audioEngine: AVAudioEngine
    private var isRecording = false
    private var loudness: Float = 0.0
    private var laughRecordingTimer:Timer?
    
    init(audioEngine: AVAudioEngine = AVAudioEngine(), speechRecognizer: SpeechRecognizer = SpeechRecognizer()) {
        self.audioEngine = audioEngine
        self.speechRecognizer = speechRecognizer
        
        super.init()
        speechRecognizer.setDelegate(delegate: self)
    }
    
    internal func listen(expectedPhrase: String?) {
        phraseHeard = ""
        isListening = true
        startSpeechRecognizer(expectedPhrase: expectedPhrase)
        stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: .seconds(3))
    }
    
    internal func listenForLaughter() {
        startLaughRecognizer()
        stopLaughRecognizer(after: .seconds(3))
    }
    
    internal func stopListening() {
        stopSpeechRecognizer()
        stopLaughRecognizer()
    }
}

extension Ear: AVAudioRecorderDelegate {
    // MARK: - Listen to Laughter
    private func startLaughRecognizer() {
        do {
            self.loudness = 0
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

            // Example usage:
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
                    self.delegate?.isHearing(nil, loudness: self.loudness)
                }
            }
        } catch {
            debugPrint("Error recording audio: \(error.localizedDescription)")
        }
    }
    
    private func stopLaughRecognizer(after time: DispatchTimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.stopLaughRecognizer()
        }
    }
    
    private func stopLaughRecognizer() {
        laughRecordingTimer?.invalidate()
        laughRecordingTimer = nil
        audioRecorder?.stop()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        print("Last loudness score")
        print(self.loudness)
        self.delegate?.didHear(nil, loudness: self.loudness)
    }
}

extension Ear: SFSpeechRecognizerDelegate {
    // MARK: - Listen Actions
    private func startSpeechRecognizer(expectedPhrase: String?) {
        do {
            speechRecognizer.setInputNode(inputNode: audioEngine.inputNode)
            speechRecognizer.configure(expectedPhrase: expectedPhrase) { phraseHeard in
                if self.isListening {
                    self.phraseHeard = phraseHeard
                    self.delegate?.isHearing(phraseHeard, loudness: nil)
                }
            } errorCompletion: { error in
                debugPrint("Error capturing speech: \(error.debugDescription)")
                self.stopSpeechRecognizer()
            }
            audioEngine.prepare()
            try audioEngine.start()
        }
        catch {
            // FIXME: - Handle Error
            debugPrint("Error setting up speech recognizer audio engine: \(error)")
        }
    }
    
    private func stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: DispatchTimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + intervalsToRecognizeSpeech) {
            if self.phraseHeard.isEmpty && self.isListening {
                // If user hasn't said anything, delay stopping speech recognizer
                self.stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: intervalsToRecognizeSpeech)
            }
            else if self.isListening {
                self.delegate?.didHear(self.phraseHeard, loudness: nil)
                self.stopSpeechRecognizer()
            }
        }
    }
    
    private func stopSpeechRecognizer() {
        isListening = false
        audioEngine.stop()
        speechRecognizer.stop()
    }
}
