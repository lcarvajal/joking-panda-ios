//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation
import Speech

class ConversationManager: NSObject, ObservableObject {
    @Published var status: ConversationStatus = .stopped
    @Published var messageHistory: String = ""
    @Published var speechOrPhraseToDisplay = " "
    
    internal var currentPhrase: String {
        return jokeManager.currentJoke.phrases[phraseIndex]
    }
    
    private let audio = Audio()
    private var jokeManager = JokeManager()
    private let speechRecognizer = SpeechRecognizer()
    private let synthesizer = AVSpeechSynthesizer()
    
    private var speechRecognized: String = ""
    private var phraseBotIsSaying: String = ""
    
    private var phraseIndex = 0
    private var personToStartTalking: Person {
        return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser
    }
    
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
            if self.messageHistory != "" {
                self.messageHistory += "\n"
            }
            
            audio.activateAudioSession()
            status = .botSpeaking
            converse()
            // FIXME: Property should get set correctly for different conversation types
            Event.track(Constant.Event.conversationStarted, properties: [
                Constant.Event.Property.conversationId: jokeManager.currentJoke.id
              ])
        }
        else {
            return
        }
    }
    
    private func converse() {
        // converse() is a recursive function that gets called again after the bot finishes speaking (in SpeechSynthesizerDelegate)
        // it also gets called again after the recording stops for a user
        
        if phraseIndex <= (jokeManager.currentJoke.phrases.count - 1) && status != .stopped {
            if personToStartTalking == .bot {
                speak(currentPhrase)
                status = .botSpeaking
            }
            else {
                status = .currentUserSpeaking
                startRecording()
                stopRecordingAndHandleRecognizedPhrase()
            }
        }
        else {
            return
        }
    }
    
    private func incrementPhraseIndex() {
        // If conversation is coming to an end, a new conversation is started by incrementing conversation index
        
        status = .noOneSpeaking
        phraseIndex += 1
        
        if phraseIndex > (jokeManager.currentJoke.phrases.count - 1) {
            phraseIndex = 0
            status = .stopped
            
            jokeManager.currentJokeWasHeard()
            //audio.deactivateAudioSession()
        }
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

extension ConversationManager: SFSpeechRecognizerDelegate {
    // MARK: - Actions
    
    private func startRecording() {
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
        
        do {
            try audio.audioEngine.start()
        }
        catch {
            // FIXME: - Handle Error
        }
    }
    
    private func stopRecordingAndHandleRecognizedPhrase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.speechRecognized.count < 1 {
                // If user hasn't said anything, wait on user input
                self.stopRecordingAndHandleRecognizedPhrase()
                return
            }
            else if Tool.levenshtein(aStr: self.speechRecognized, bStr: self.currentPhrase) < 5 {
                self.messageHistory += "\n🗣️ \(self.currentPhrase)"
            }
            else {
                self.messageHistory += "\n🗣️ \(self.speechRecognized)"
            }
            
            self.stopRecording()
            self.updateSpeechOrPhraseToDisplay()
            self.incrementPhraseIndex()
            self.converse()
        }
    }
    
    private func stopRecording() {
        audio.stopAudioEngine()
        speechRecognizer.stop()
    }
    
    private func updateMessageHistoryForPanda() {
        if messageHistory == "" {
            messageHistory += "🐼 \(currentPhrase)"
        }
        else {
            messageHistory += "\n🐼 \(currentPhrase)"
        }
    }
}

extension ConversationManager: AVSpeechSynthesizerDelegate {
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        phraseBotIsSaying = (utterance.speechString as NSString).substring(with: characterRange)
        updateSpeechOrPhraseToDisplay()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        synthesizer.stopSpeaking(at: .immediate)
        updateMessageHistoryForPanda()
        incrementPhraseIndex()
        converse()
    }
}

extension ConversationManager: AVAudioPlayerDelegate {
    // MARK: - Actions
    
    private func speak(_ text: String) {
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
        updateMessageHistoryForPanda()
        incrementPhraseIndex()
        converse()
    }
}
