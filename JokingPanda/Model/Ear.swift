//
//  Ear.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 5/7/24.
//

import Foundation
import Speech

class Ear: NSObject, ObservableObject {
    @Published var phraseHeard: String = ""
    
    private let audio: Audio
    private var listenCompletion: ((String) -> Void)?
    private let speechRecognizer = SpeechRecognizer()
    
    init(audio: Audio) {
        self.audio = audio
    }
    
    internal func listen(expectedPhrase: String?, completion: @escaping (_ phraseHeard: String) -> Void) {
        phraseHeard = ""
        listenCompletion = completion
        
        setUpSpeechRecognizer(expectedPhrase: expectedPhrase)
        activateSpeechRecognizer()
        stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: .seconds(3))
    }
}

extension Ear: SFSpeechRecognizerDelegate {
    // MARK: - Listen Actions
    
    private func setUpSpeechRecognizer(expectedPhrase: String?) {
        speechRecognizer.setInputNode(inputNode: audio.audioEngine.inputNode)
        speechRecognizer.configure(expectedPhrase: expectedPhrase) { phraseHeard in
            self.phraseHeard = phraseHeard
        } errorCompletion: { error in
            debugPrint("Error capturing speech: \(error.debugDescription)")
            self.audio.audioEngine.stop()
        }
        audio.audioEngine.prepare()
    }
    
    private func activateSpeechRecognizer() {
        do {
            try audio.audioEngine.start()
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
                self.audio.stopAudioEngine()
                self.speechRecognizer.stop()
            }
        }
    }
}
