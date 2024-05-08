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
    func currentPhraseDidUpdate(phrase: String, person: Person)
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
        updateAction(.stopped)
        mouth.stopSpeaking()
        ear.stopListening()
    }
    
    /**
     Recursive function where the bot starts to speak, listens to a response, and speaks again if needed.
     */
    private func speak(phrase: String) {
        updateAction(.speaking)
        mouth.speak(phrase: phrase)
    }
    
    /**
     Sets action to listening, captures what a user says, adjusts it based on expected phrase, and remembers the phrase heard.
     */
    private func listen(expectedPhrase: String?) {
        updateAction(.listening)
        ear.listen(expectedPhrase: expectedPhrase)
    }
    
    /**
     Depending on the conversation history and current conversation, this function calls `speak()` again or sets action to stop since the conversation is over.
     */
    private func respond(to phraseHeard: String) {
        if let response = brain.getResponsePhrase(for: phraseHeard) {
            self.speak(phrase: response)
        }
        else {
            self.updateAction(.stopped)
        }
    }
    
    private func updateAction(_ updatedAction: AnimationAction) {
        action = updatedAction
        delegate?.actionDidUpdate(action: updatedAction)
    }
}

extension Bot: EarDelegate {
    func isHearingPhrase(_ phrase: String) {
        delegate?.currentPhraseDidUpdate(phrase: phrase, person: .currentUser)
    }
    
    func didHearPhrase(_ phrase: String) {
        let interpretedPhrase = self.brain.interpret(phraseHeard: phrase, phraseExpected: phrase)
        brain.remember(interpretedPhrase, saidBy: .currentUser)
        delegate?.currentPhraseDidUpdate(phrase: "", person: .currentUser)
        delegate?.phraseHistoryDidUpdate(phraseHistory: brain.getPhraseHistory())
        updateAction(.stopped)
        respond(to: interpretedPhrase)
    }
}

extension Bot: MouthDelegate {
    func isSayingPhrase(_ phrase: String) {
        delegate?.currentPhraseDidUpdate(phrase: phrase, person: .bot)
    }
    
    func didSayPhrase(_ phrase: String) {
        brain.remember(phrase, saidBy: .bot)
        delegate?.currentPhraseDidUpdate(phrase: "", person: .currentUser)
        delegate?.phraseHistoryDidUpdate(phraseHistory: brain.getPhraseHistory())
        updateAction(.stopped)
        listen(expectedPhrase: "Continue")
    }
}
