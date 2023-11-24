//
//  SpeakAndListen.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//
// Manages Audio, Speech Synthesis, and Speech Recognition
// Updates UI based on conversation

import Foundation
import Speech

class SpeakAndListen: NSObject, ObservableObject {
    @Published var animationCharacter: AnimationCharacter = .tuxedoPanda
    @Published var animationStatus: AnimationStatus = .stopped
    @Published var speechOrPhraseToDisplay = " "
    @Published var conversationManager = ConversationManager()
    
    private var recognizedSpeech: String = ""
    private var phraseBotIsSaying: String = ""
    
    private let audio = Audio()
    private let speechRecognizer = SpeechRecognizer()
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        synthesizer.delegate = self
        speechRecognizer.setDelegate(delegate: self)
    }
    
    // MARK: - Setup
    
    // MARK: - Actions
    
    internal func startConversation(type: ConversationType? = nil) {
        if !conversationManager.isConversing {
            conversationManager.startConversation(type: type)
            audio.activateAudioSession()
            updateAnimation(status: .speaking)
            speak(conversationManager.currentPhrase)
        }
        else {
            return
        }
    }
    
    internal func stopConversation() {
        conversationManager.stopConversation()
        synthesizer.stopSpeaking(at: .immediate)
        audio.deactivateAudioPlayer()
        stopRecording()
        updateAnimation(status: .stopped)
    }
    
    internal func converse() {
        if conversationManager.isConversing {
            if conversationManager.personTalking == .bot {
                speak(conversationManager.currentPhrase)
                updateAnimation(status: .speaking)
            }
            else {
                updateAnimation(status: .listening)
                startRecording()
                stopRecordingAndHandleRecognizedPhrase()
            }
        }
        else {
            // When phrases for conversation are done, end recursive conversation.
            return
        }
    }
    
    private func updateSpeechOrPhraseToDisplay() {
        if conversationManager.personTalking == .bot {
            speechOrPhraseToDisplay = "🐼 \(phraseBotIsSaying)"
        }
        else {
            speechOrPhraseToDisplay = "🎙️ \(recognizedSpeech)"
        }
    }
    
    internal func updateAnimation(status: AnimationStatus) {
        switch conversationManager.selectedType {
        case .dancing:
            animationCharacter = .coolPanda
        case .deciding, .joking:
            animationCharacter = .tuxedoPanda
        case .journaling:
            animationCharacter = .sittingPanda
        }
        
        if conversationManager.isConversing && conversationManager.selectedType == .joking {
            animationStatus = Animation.animationStatusFor(person: conversationManager.personTalking, phrase: conversationManager.currentPhrase)
        }
        else {
            animationStatus = status
        }
        
    }
    
    // MARK: - Events
    
    internal func speechOrAudioDidFinish() {
        animationStatus = .dancing
        conversationManager.queueNextPhrase()
        
        if conversationManager.isConversing {
            // Creates a recursive function for conversation
            converse()
        }
        else {
            updateAnimation(status: .stopped)
        }
    }
}

extension SpeakAndListen: SFSpeechRecognizerDelegate {
    // MARK: - Actions
    
    internal func startRecording() {
        do {
            recognizedSpeech = ""
            updateSpeechOrPhraseToDisplay()
            
            speechRecognizer.setInputNode(inputNode: audio.audioEngine.inputNode)
            speechRecognizer.configure(expectedPhrase: conversationManager.currentPhrase) { recognizedSpeech in
                self.recognizedSpeech = recognizedSpeech
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
            if self.conversationManager.isConversing {
                if self.recognizedSpeech.count < 1 {
                    // If user hasn't said anything, wait on user input
                    self.stopRecordingAndHandleRecognizedPhrase()
                    return
                }
                else {
                    self.conversationManager.updateConversationHistory(self.recognizedSpeech)
                }
                
                self.stopRecording()
                self.updateSpeechOrPhraseToDisplay()
                self.speechOrAudioDidFinish()
            }
            else {
                return
            }
        }
    }
    
    private func stopRecording() {
        audio.stopAudioEngine()
        speechRecognizer.stop()
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
        conversationManager.updateConversationHistory()
        speechOrAudioDidFinish()
    }
}

extension SpeakAndListen: AVAudioPlayerDelegate {
    // MARK: - Actions
    
    internal func speak(_ text: String) {
        updateAnimation(status: .speaking)
        
        let audioFileName = Tool.removePunctuation(from: text)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        
        if conversationManager.selectedType == .dancing {
            if let audioURL = Bundle.main.url(forResource: audioFileName, withExtension: "mp3") {
                audio.play(url: audioURL, delegate: self)
                updateAnimation(status: .dancing)
            }
            else {
                // FIXME: Handle error
                print("Problem playing song")
                print(audioFileName)
            }
        }
        else {
            if let audioURL = Bundle.main.url(forResource: audioFileName, withExtension: "m4a") {
                audio.play(url: audioURL, delegate: self)
                phraseBotIsSaying = conversationManager.currentPhrase
                updateSpeechOrPhraseToDisplay()
            }
            else {
                // Fallback on voice synthesis if audio file doesn't exist
                self.synthesizer.botSpeak(string: text)
            }
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // FIXME: Handle successful and unsuccessful cases
        audio.deactivateAudioPlayer()
        conversationManager.updateConversationHistory()
        speechOrAudioDidFinish()
    }
}
