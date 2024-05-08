//
//  Bot.swift
//  JokingPanda
//
/*
 A bot holds all of the different components of haha panda together. It speaks, listens to user, then speaks again if needed, all while remembering the conversation.
 */

import Foundation
import Speech

protocol BotDelegate: AnyObject {
    func actionDidUpdate(action: AnimationAction)
    func currentPhraseDidUpdate(phrase: String)
    func phraseHistoryDidUpdate(phraseHistory: String)
}

class Bot: NSObject, ObservableObject  {
    internal weak var delegate: BotDelegate?
    
    private var action: AnimationAction = .stopped   // Animate based on current action
    private var brain: Brain = Brain() // Decides what to say and remembers what was said / heard
    private let ear: Ear = Ear() // Listens to phrases said by user
    private var mouth: Mouth = Mouth() // Says phrases outloud
    
    override init() {
        super.init()
        ear.delegate = self
        mouth.delegate = self
    }
    
    /**
    Kick off conversation.
     */
    internal func startConversation() {
        let initalPhrase = brain.getInitalPhrase()
        speak(phrase: initalPhrase)
    }
    
    /**
     Stops speaking and listening.
     */
    internal func stopEverything() {
        action = .stopped
        triggerActionUpdate()
        mouth.stopSpeaking()
        ear.stopListening()
    }
    
    /**
     Recursive function where the bot starts to speak, listens to a response, and speaks again if needed.
     */
    private func speak(phrase: String) {
        action = .speaking
        triggerActionUpdate()
        mouth.speak(phrase: phrase)
    }
    
    /**
     Sets action to listening, captures what a user says, adjusts it based on expected phrase, and remembers the phrase heard.
     */
    private func listen(expectedPhrase: String?) {
        action = .listening
        triggerActionUpdate()
        ear.listen(expectedPhrase: expectedPhrase)
    }
    
    /**
     Depending on the conversation history and current conversation, this function calls `speak()` again or sets action to stop since the conversation is over.
     */
    private func respond(to phraseHeard: String) {
        if let response = brain.getResponsePhrase(for: phraseHeard) {
            speak(phrase: response)
        }
        else {
            action = .stopped
            triggerActionUpdate()
        }
    }
    
    /**
     Trigger current phrase update for view model to show what is being said / heard.
     */
    private func triggerCurrentPhraseUpdate(phrase: String, person: Person) {
        let currentPhrase: String
        
        switch person {
        case .bot:
            currentPhrase = "🐼 \(phrase)"
        case .currentUser:
            currentPhrase = "🎙️ \(phrase)"
        }
        
        delegate?.currentPhraseDidUpdate(phrase: currentPhrase)
    }
    
    /**
     Trigger action update for view model to show different animations based on actions.
     */
    private func triggerActionUpdate() {
        delegate?.actionDidUpdate(action: action)
    }
    
    /**
     Trigger phrase history update for view model to show all phrases said / heard.
     */
    private func triggerPhraseHistoryUpdate() {
        delegate?.phraseHistoryDidUpdate(phraseHistory: brain.getPhraseHistory())
    }
}

extension Bot: EarDelegate {
    func isHearingPhrase(_ phrase: String) {
        triggerCurrentPhraseUpdate(phrase: phrase, person: .currentUser)
    }
    
    func didHearPhrase(_ phrase: String) {
        
        let interpretedPhrase = self.brain.interpret(phraseHeard: phrase, phraseExpected: phrase)
        brain.remember(interpretedPhrase, saidBy: .currentUser)
        
        triggerCurrentPhraseUpdate(phrase: "", person: .bot)
        triggerPhraseHistoryUpdate()
        
        action = .stopped
        triggerActionUpdate()
        
        respond(to: interpretedPhrase)
    }
}

extension Bot: MouthDelegate {
    func isSayingPhrase(_ phrase: String) {
        triggerCurrentPhraseUpdate(phrase: phrase, person: .bot)
    }
    
    func didSayPhrase(_ phrase: String) {
        brain.remember(phrase, saidBy: .bot)
        
        triggerCurrentPhraseUpdate(phrase: "", person: .currentUser)
        triggerPhraseHistoryUpdate()
        
        action = .stopped
        triggerActionUpdate()
        
        listen(expectedPhrase: "Continue")
    }
}
