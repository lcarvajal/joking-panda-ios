//
//  Bot.swift
//  JokingPanda
//
/*
 A bot holds all of the different components of haha panda together. It speaks, listens to user, then speaks again if needed, all while remembering the conversation.
 */

import Foundation
import Speech

class Bot: NSObject, ObservableObject  {
    @Published var action: AnimationAction = .stopped   // Animate based on current action
    @Published var mouth: Mouth // Says phrases outloud
    @Published var ear: Ear // Listens to phrases said by user
    @Published var brain: Brain // Decides what to say and remembers what was said / heard
    
    private let audio: Audio
    
    override init() {
        audio = Audio()
        mouth = Mouth(audio: audio)
        ear = Ear(audio: audio)
        brain = Brain()
        super.init()
    }
    
    /**
     Recursive function where the bot starts to speak, listens to a response, and speaks again if needed.
     */
    internal func converse(phrase: String) {
        self.speak(phrase: phrase) {
            self.listen(expectedPhrase: nil) { phraseHeard in
                self.respond(to: phraseHeard)
            }
        }
    }
    
    /**
     Sets action to speaking, says a phrase outloud, and remembers the phrase being said.
     */
    private func speak(phrase: String, completion: @escaping (() -> Void)) {
        action = .speaking
        mouth.speak(phrase: phrase) {
            self.brain.remember(phrase, saidBy: .bot)
            completion()
        }
    }
    
    /**
     Sets action to listening, captures what a user says, adjusts it based on expected phrase, and remembers the phrase heard.
     */
    private func listen(expectedPhrase: String?, completion: @escaping ((String) -> Void)) {
        action = .listening
        ear.listen(expectedPhrase: expectedPhrase) { phraseHeard in
            let interpretedPhrase = self.brain.interpret(phraseHeard: phraseHeard, phraseExpected: phraseHeard)
            self.brain.remember(interpretedPhrase, saidBy: .bot)
            completion(interpretedPhrase)
        }
    }
    
    /**
     Depending on the conversation history and current conversation, this function calls `converse()` again or sets action to stop since the conversation is over.
     */
    private func respond(to phraseHeard: String) {
        if let response = brain.getResponsePhrase(for: phraseHeard) {
            self.converse(phrase: response)
        }
        else {
            self.action = .stopped
        }
    }
}
