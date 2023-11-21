//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation
import Speech

class ConversationManager: SpeakAndListen {
    override var currentPhrase: String {
        return jokeManager.currentJoke.phrases[phraseIndex]
    }
    
    private var jokeManager = JokeManager()
    private var phraseIndex = 0
    private var personToStartTalking: Person {
        return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser
    }
    
    // MARK: - Setup
    
    // MARK: - Actions
    
    override func startConversation() {
        if status == .stopped {
            // FIXME: Property should get set correctly for different conversation types
            Event.track(Constant.Event.conversationStarted, properties: [
                Constant.Event.Property.conversationId: jokeManager.currentJoke.id
              ])
        }
        super.startConversation()
    }
    
    override func converse() {
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
            // When phrases for conversation are done, end recursive conversation.
            return
        }
    }
    
    // MARK: - Events
    
    override func speechOrAudioDidFinish() {
        // If conversation is coming to an end, a new conversation is started by incrementing conversation index
        status = .noOneSpeaking
        phraseIndex += 1
        
        if phraseIndex > (jokeManager.currentJoke.phrases.count - 1) {
            phraseIndex = 0
            status = .stopped
            
            jokeManager.currentJokeWasHeard()
        }
        super.speechOrAudioDidFinish()
    }
}
