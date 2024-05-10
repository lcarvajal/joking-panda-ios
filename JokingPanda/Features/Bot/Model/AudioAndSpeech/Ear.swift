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
    private let speechRecognizer = SpeechRecognizer()
    private var isListening = false
    
    private var audioRecorder: AVAudioRecorder!
    private var isRecording = false
    private var loudness: Float = 0.0
    
    override init() {
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
        stopLaughRecognizer(after: .seconds(4))
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
            AudioManager.shared.activateRecordingAudioSession()

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
                self.audioRecorder.delegate = self
                self.audioRecorder.prepareToRecord()
                self.audioRecorder.isMeteringEnabled = true
                self.audioRecorder.record()
                self.isRecording = true
            }
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                self.audioRecorder.updateMeters()
                self.loudness = self.audioRecorder.averagePower(forChannel: 0)
                self.delegate?.isHearing(nil, loudness: self.loudness)
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
        audioRecorder.stop()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        self.delegate?.didHear(nil, loudness: self.loudness)
    }
}

extension Ear: SFSpeechRecognizerDelegate {
    // MARK: - Listen Actions
    private func startSpeechRecognizer(expectedPhrase: String?) {
        do {
            speechRecognizer.setInputNode(inputNode: AudioManager.shared.audioEngine.inputNode)
            speechRecognizer.configure(expectedPhrase: expectedPhrase) { phraseHeard in
                if self.isListening {
                    self.phraseHeard = phraseHeard
                    self.delegate?.isHearing(phraseHeard, loudness: nil)
                }
            } errorCompletion: { error in
                debugPrint("Error capturing speech: \(error.debugDescription)")
                self.stopSpeechRecognizer()
            }
            AudioManager.shared.audioEngine.prepare()
            try AudioManager.shared.audioEngine.start()
        }
        catch {
            // FIXME: - Handle Error
            debugPrint("Error setting up speech recognizer audio engine: \(error)")
        }
    }
    
    private func stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: DispatchTimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + intervalsToRecognizeSpeech) {
            if self.phraseHeard.isEmpty {
                // If user hasn't said anything, delay stopping speech recognizer
                self.stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: intervalsToRecognizeSpeech)
            }
            else {
                self.delegate?.didHear(self.phraseHeard, loudness: nil)
                self.stopSpeechRecognizer()
            }
        }
    }
    
    private func stopSpeechRecognizer() {
        isListening = false
        AudioManager.shared.stopAudioEngine()
        speechRecognizer.stop()
    }
}
