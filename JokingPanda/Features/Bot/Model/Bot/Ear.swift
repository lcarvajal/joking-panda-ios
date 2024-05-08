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
    func isHearingPhrase(_ phrase: String)
    func didHearPhrase(_ phrase: String)
}

class Ear: NSObject {
    internal weak var delegate: EarDelegate?
    private var phraseHeard: String = ""
    private let speechRecognizer = SpeechRecognizer()
    private var isListening = false
    
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
    
    internal func stopListening() {
        isListening = false
        AudioManager.shared.stopAudioEngine()
        speechRecognizer.stop()
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
                    self.delegate?.isHearingPhrase(phraseHeard)
                }
            } errorCompletion: { error in
                debugPrint("Error capturing speech: \(error.debugDescription)")
                self.stopListening()
            }
            AudioManager.shared.audioEngine.prepare()
            try AudioManager.shared.audioEngine.start()
        }
        catch {
            // FIXME: - Handle Error
        }
    }
    
    private func stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: DispatchTimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + intervalsToRecognizeSpeech) {
            if self.phraseHeard.isEmpty {
                // If user hasn't said anything, delay stopping speech recognizer
                self.stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: intervalsToRecognizeSpeech)
            }
            else {
                self.delegate?.didHearPhrase(self.phraseHeard)
                self.stopListening()
            }
        }
    }
}
