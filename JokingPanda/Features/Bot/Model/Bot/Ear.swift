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
    
    override init() {
        super.init()
        speechRecognizer.setDelegate(delegate: self)
    }
    
    internal func listen(expectedPhrase: String?) {
        phraseHeard = ""
        setUpSpeechRecognizer(expectedPhrase: expectedPhrase)
        activateSpeechRecognizer()
        stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: .seconds(3))
    }
    
    internal func stopListening() {
        AudioManager.shared.stopAudioEngine()
        speechRecognizer.stop()
    }
}

extension Ear: SFSpeechRecognizerDelegate {
    // MARK: - Listen Actions
    
    private func setUpSpeechRecognizer(expectedPhrase: String?) {
        speechRecognizer.setInputNode(inputNode: AudioManager.shared.audioEngine.inputNode)
        speechRecognizer.configure(expectedPhrase: expectedPhrase) { phraseHeard in
            self.phraseHeard = phraseHeard
            self.delegate?.isHearingPhrase(phraseHeard)
        } errorCompletion: { error in
            debugPrint("Error capturing speech: \(error.debugDescription)")
            self.stopListening()
        }
        AudioManager.shared.audioEngine.prepare()
    }
    
    private func activateSpeechRecognizer() {
        do {
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
