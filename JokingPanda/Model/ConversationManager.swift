//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation
import Mixpanel
import Speech

class ConversationManager: NSObject, ObservableObject {
    @Published var status: ConversationStatus = .stopped
    @Published var messageHistory: String = ""
    @Published var speechOrPhraseToDisplay = " "
    
    internal var currentPhrase: String {
        return conversations[conversationIndex].phrases[phraseIndex]
    }
    
    private let audio = Audio()
    private let speechRecognizer = SpeechRecognizer()
    private let synthesizer = AVSpeechSynthesizer()
    
    private var speechRecognized: String = ""
    private var phraseBotIsSaying: String = ""
    
    private var conversationIndex = 0
    private var phraseIndex = 0
    private var personToStartTalking: Person {
        return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser
    }
    
    private let conversations: [Conversation] = Tool.load("conversationData.json")
    
    override init() {
        super.init()
        synthesizer.delegate = self
        speechRecognizer.setDelegate(delegate: self)
        
        setConversationIndexOfLastConversation()
    }
    
    // MARK: - Setup
    
    private func setConversationIndexOfLastConversation() {
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.conversationId)
        if let index = conversations.firstIndex(where: { $0.id == id }) {
            conversationIndex = index
        }
    }
    
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
            
            #if DEBUG
                print("\(Constant.Event.conversationStarted) Event not tracked in DEBUG")
            #else
                // Track conversation started
                Mixpanel.mainInstance().track(event: Constant.Event.conversationStarted,
                                              properties: [
                                                Constant.Event.Property.conversationId: conversations[conversationIndex].id
                                              ])
            #endif
        }
        else {
            return
        }
    }
    
    private func converse() {
        // converse() is a recursive function that gets called again after the bot finishes speaking (in SpeechSynthesizerDelegate)
        // it also gets called again after the recording stops for a user
        
        if phraseIndex <= (conversations[conversationIndex].phrases.count - 1) && status != .stopped {
            if personToStartTalking == .bot {
                speak(currentPhrase)
                status = .botSpeaking
            }
            else {
                do {
                    status = .currentUserSpeaking
                    try startRecording()
                    stopRecordingAndHandleRecognizedPhrase()
                }
                catch {
                    // FIXME: Handle error starting recording
                }
            }
        }
        else {
            return
        }
    }
    
    private func incrementPhraseIndex() {
        status = .noOneSpeaking
        phraseIndex += 1
        
        if phraseIndex > (conversations[conversationIndex].phrases.count - 1) {
            phraseIndex = 0
            conversationIndex += 1
            status = .stopped
            
            if conversationIndex > (conversations.count - 1) {
                conversationIndex = 0
                audio.deactivateAudioSession()
            }
            
            UserDefaults.standard.set(conversations[conversationIndex].id, forKey: Constant.UserDefault.conversationId)
        }
    }
    
    private func speak(_ text: String) {
        status = .botSpeaking
        
        let audioFileName = Tool.removePunctuation(from: text)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        
        if let audioURL = Bundle.main.url(forResource: "\(audioFileName)", withExtension: "m4a") {
            audio.play(url: audioURL, delegate: self)
            phraseBotIsSaying = currentPhrase
            updateSpeechOrPhraseToDisplay()
        }
        else {
            // Fallback on voice synthesis if audio file doesn't exist
            self.synthesizer.botSpeak(string: text)
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
    
    private func startRecording() throws {
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
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // FIXME: Handle successful and unsuccessful cases
        audio.deactivateAudioPlayer()
        updateMessageHistoryForPanda()
        incrementPhraseIndex()
        converse()
    }
}
