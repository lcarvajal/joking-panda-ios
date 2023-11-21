//
//  SpeakAndListen.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//
// Manages Audio, Speech Synthesis, and Speech Recognition
// Updates published properties so that they can be displayed in a UI

import Foundation
import Speech

class SpeakAndListen: NSObject, ObservableObject {
    @Published var status: ConversationStatus = .stopped
    @Published var conversationHistory: String = ""
    @Published var speechOrPhraseToDisplay = " "
    
    internal var currentPhrase: String {
        // FIXME: Require property to be overriden
        return ""
    }
    
    private let audio = Audio()
    private let speechRecognizer = SpeechRecognizer()
    private let synthesizer = AVSpeechSynthesizer()
    
    private var speechRecognized: String = ""
    private var phraseBotIsSaying: String = ""
    
    override init() {
        super.init()
        synthesizer.delegate = self
        speechRecognizer.setDelegate(delegate: self)
    }
    
    // MARK: - Setup
    
    // MARK: - Actions
    
    internal func startConversation() {
        // Only start a new conversation if there is no ongoing conversation
        if status == .stopped {
            if self.conversationHistory != "" {
                self.conversationHistory += "\n"
            }
            
            audio.activateAudioSession()
            status = .botSpeaking
            converse()
        }
        else {
            return
        }
    }
    
    internal func converse() {
        // FIXME: Require function to be overriden
        // A recursive function called after the bot finishes speaking
        // and after the recording stops for a user
    }
    
    internal func startNextPhraseInConversation() {
        // FIXME: Require function to be overriden
        converse()
    }
    
    
    private func updateSpeechOrPhraseToDisplay() {
        switch status {
        case .botSpeaking:
            speechOrPhraseToDisplay = "🐼 \(phraseBotIsSaying)"
        case .currentUserSpeaking:
            speechOrPhraseToDisplay = "🎙️ \(speechRecognized)"
        default:
            speechOrPhraseToDisplay = " "
        }
    }
}

extension SpeakAndListen: SFSpeechRecognizerDelegate {
    // MARK: - Actions
    
    internal func startRecording() {
        do {
            speechRecognized = ""
            updateSpeechOrPhraseToDisplay()
            
            speechRecognizer.setInputNode(inputNode: audio.audioEngine.inputNode)
            speechRecognizer.configure(expectedPhrase: currentPhrase) { recognizedSpeech in
                self.speechRecognized = recognizedSpeech
                self.updateSpeechOrPhraseToDisplay()
            } errorCompletion: { error in
                // Stop recognizing speech if there is a problem.
                self.audio.audioEngine.stop()
            }
            
            audio.audioEngine.prepare()
            try audio.audioEngine.start()
        }
        catch {
            // FIXME: - Handle Error
        }
    }
    
    internal func stopRecordingAndHandleRecognizedPhrase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.speechRecognized.count < 1 {
                // If user hasn't said anything, wait on user input
                self.stopRecordingAndHandleRecognizedPhrase()
                return
            }
            else {
                self.updateconversationHistoryForPerson()
            }
            
            self.stopRecording()
            self.updateSpeechOrPhraseToDisplay()
            self.startNextPhraseInConversation()
        }
    }
    
    private func stopRecording() {
        audio.stopAudioEngine()
        speechRecognizer.stop()
    }
    
    private func updateconversationHistoryForBot() {
        if conversationHistory == "" {
            conversationHistory += "🐼 \(currentPhrase)"
        }
        else {
            conversationHistory += "\n🐼 \(currentPhrase)"
        }
    }
    
    private func updateconversationHistoryForPerson() {
        if Tool.levenshtein(aStr: self.speechRecognized, bStr: self.currentPhrase) < 5 {
            self.conversationHistory += "\n🗣️ \(self.currentPhrase)"
        }
        else {
            self.conversationHistory += "\n🗣️ \(self.speechRecognized)"
        }
    }
}

extension SpeakAndListen: AVSpeechSynthesizerDelegate {
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        phraseBotIsSaying = (utterance.speechString as NSString).substring(with: characterRange)
        updateSpeechOrPhraseToDisplay()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        synthesizer.stopSpeaking(at: .immediate)
        updateconversationHistoryForBot()
        startNextPhraseInConversation()
    }
}

extension SpeakAndListen: AVAudioPlayerDelegate {
    // MARK: - Actions
    
    internal func speak(_ text: String) {
        status = .botSpeaking
        
        let audioFileName = Tool.removePunctuation(from: text)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        
        if let audioURL = Bundle.main.url(forResource: audioFileName, withExtension: "m4a") {
            audio.play(url: audioURL, delegate: self)
            phraseBotIsSaying = currentPhrase
            updateSpeechOrPhraseToDisplay()
        }
        else {
            // Fallback on voice synthesis if audio file doesn't exist
            self.synthesizer.botSpeak(string: text)
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // FIXME: Handle successful and unsuccessful cases
        audio.deactivateAudioPlayer()
        updateconversationHistoryForBot()
        startNextPhraseInConversation()
    }
}


