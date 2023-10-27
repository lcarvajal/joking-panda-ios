//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation
import Speech

class ConversationManager: NSObject, ObservableObject {
    internal var speaker = Speaker()
    internal var speechRecognizer = SpeechRecognizer()
    internal var isConversing = false
    
    private var conversations: [Conversation] = JokingPanda.load("conversationData.json")
    private var conversationIndex = 0
    private var phraseIndex = 0
    
    override init() {
        super.init()
        speechRecognizer.speechRecognizer.delegate = self
        speaker.synthesizer.delegate = self
    }

    internal func converse() {
        if phraseIndex <= (conversations[conversationIndex].phrases.count - 1) {
            isConversing = true
            speaker.speak(currentPhrase())
//            if personToStartTalking() == .bot {
//                speaker.speak(currentPhrase())
//            }
//            else {
//                do {
//                    print("Expected user phrase: \(currentPhrase())")
//                    try speechRecognizer.startRecording()
//                    // When recording is finished increment phrase counter and stop recording
//    //                incrementPhraseIndex()
//                    // if phrase index isn't finished, call function again
//    //                converse()
//                }
//                catch {
//                    print("Problem starting recording...")
//                }
//            }
        }
        else {
            isConversing = false
            return
        }
    }
    
    private func personToStartTalking() -> Person {
        if phraseIndex % 2 == 0  {
            return Person.bot
        }
        else {
            return Person.currentUser
        }
    }
    
    private func currentPhrase() -> String {
        return conversations[conversationIndex].phrases[phraseIndex]
    }
    
    private func incrementPhraseIndex() {
        phraseIndex += 1

        if phraseIndex > (conversations[conversationIndex].phrases.count - 1) {
            phraseIndex = 0
            conversationIndex += 1
            isConversing = false

            if conversationIndex > (conversations.count - 1) {
                conversationIndex = 0
            }
        }
        print("Next phrase: \(conversations[conversationIndex].phrases[phraseIndex])")
    }
}


extension ConversationManager: SFSpeechRecognizerDelegate {
    
}

extension ConversationManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        self.isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
//        self.isSpeaking = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        self.isSpeaking = false
        // Stop speaker and start recording after speaker is finished...
        speaker.stop()
        incrementPhraseIndex()
        if isConversing {
            converse()
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
