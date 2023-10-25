//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation

struct ConversationManager {
    private var conversations: [Conversation] = [Conversation(
        phrases: ["Hey, want to hear a joke?", "Yes.", "Knock, knock!", "Who's there?", "Joking.", "Joking who?", "Joking panda!"]
    )]
    private var conversationIndex = 0
    private var phraseIndex = 0
    
    internal mutating func incrementPhraseIndex() {
        phraseIndex += 1
        
        if phraseIndex > (conversations[conversationIndex].phrases.count - 1) {
            phraseIndex = 0
        }
        print("Next phrase: \(conversations[conversationIndex].phrases[phraseIndex])")
    }

    internal func currentPhrase() -> String {
        return conversations[conversationIndex].phrases[phraseIndex]
    }
    
    internal func personToStartTalking() -> Person {
        if phraseIndex % 2 == 0  {
            return Person.bot
        }
        else {
            return Person.currentUser
        }
    }
}
