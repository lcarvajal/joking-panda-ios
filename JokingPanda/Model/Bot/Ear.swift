//
//  Ear.swift
//  JokingPanda
//
/*
 Uses speech recognition to 'hear' what a user says and updates `phraseHeard` as a user says something.
 */

import Foundation
import Speech

class Ear: NSObject, ObservableObject {
    @Published var phraseHeard: String = ""
    
    private var listenCompletion: ((String) -> Void)?
    private let speechRecognizer = SpeechRecognizer()
    
    override init() {
        super.init()
        speechRecognizer.setDelegate(delegate: self)
    }
    
    internal func listen(expectedPhrase: String?, completion: @escaping (_ phraseHeard: String) -> Void) {
        phraseHeard = ""
        listenCompletion = completion
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
                if let completion = self.listenCompletion {
                    completion(self.phraseHeard)
                }
                self.stopListening()
            }
        }
    }
}
