//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//

import Foundation

struct ConversationManager {
    internal var currentPhrase: String { return currentJoke.phrases[phraseIndex] }
    internal var isStartOfConversation: Bool { return phraseIndex == 0 }
    internal var isConversing: Bool { return phraseIndex <= (currentJoke.phrases.count - 1) }
    internal var personToStartTalking: Person { return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser }
    
    private var currentJoke: Conversation { return knockKnockJokes[index] }
    private var index = 0
    private var phraseIndex = 0
    private let knockKnockJokes: [Conversation] = Tool.load("knockKnockJokeData.json")
    
    // MARK: - Setup
    
    init() {
        setIndexFromLastJokeHeard()
    }
    
    private mutating func setIndexFromLastJokeHeard() {
        // FIXME: Property should get set correctly for jokes
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.conversationId)
        if let index = knockKnockJokes.firstIndex(where: { $0.id == id }) {
            self.index = index
        }
    }
    
    // MARK: - Actions
    
    internal mutating func queueNextPhrase() {
        phraseIndex += 1
        
        if phraseIndex > (currentJoke.phrases.count - 1) {
            phraseIndex = 0
            queueNextConversation()
        }
    }
    
    private mutating func queueNextConversation() {
        index += 1
        
        if index > (knockKnockJokes.count - 1) {
            index = 0
        }
        // FIXME: Property should get set correctly for jokes
        UserDefaults.standard.set(knockKnockJokes[index].id, forKey: Constant.UserDefault.conversationId)
    }
}
