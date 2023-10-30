//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation
import Speech

enum ConversationStatus {
    case botSpeaking
    case currentUserSpeaking
    case noOneSpeaking
    case stopped
}

class ConversationManager: NSObject, ObservableObject {
    @Published var status: ConversationStatus = .stopped
    
    private let audioSession = AVAudioSession.sharedInstance()
    private let speaker = Speaker()
    private let speechRecognizer = SpeechRecognizer()
    private let conversations: [Conversation] = Tool.load("conversationData.json")
    
    private var conversationIndex = 0
    private var phraseIndex = 0
    
    override init() {
        super.init()
        speaker.synthesizer.delegate = self
        speechRecognizer.speechRecognizer.delegate = self
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .videoChat, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            print("Error activating audio session: \(error)")
        }
    }
    
    internal func startConversation() {
        status = .botSpeaking
        converse()
    }

    private func converse() {
        print("Phrase index: \(phraseIndex)")
        print(personToStartTalking())
        print("status: \(status)")
        
        if phraseIndex <= (conversations[conversationIndex].phrases.count - 1) && status != .stopped {
            if personToStartTalking() == .bot {
                speaker.speak(currentPhrase())
                status = .botSpeaking
            }
            else {
                do {
                    print("Expected user phrase: \(currentPhrase())")
                    status = .currentUserSpeaking
                    
                    try speechRecognizer.startRecording()
                    
                    // FIXME: - Logic for recording must go inside speech recognition function in order to create actions for different input
                    let seconds = 4.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        print("Recording stopped with this speech recognized: \(self.speechRecognizer.speechRecognized)")
                        self.speechRecognizer.stopRecording()
                        self.incrementPhraseIndex()
                        print("Start next part of conversation")
                        
                        self.converse()
                    }
                }
                catch {
                    print("Problem starting recording...")
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
            }
        }
        print("Next phrase: \(conversations[conversationIndex].phrases[phraseIndex])")
    }
    
    private func personToStartTalking() -> Person {
        return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser
    }
    
    private func currentPhrase() -> String {
        return conversations[conversationIndex].phrases[phraseIndex]
    }
}

extension ConversationManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Availability of microphone changed: \(available)")
    }
}

extension ConversationManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speaker.stop()
        incrementPhraseIndex()
        converse()
    }
}
