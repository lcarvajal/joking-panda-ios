//
//  Conversations.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/22/23.
//

import Foundation

class Conversations {
    internal let type: ConversationType
    internal var currentConversation: Conversation { return conversations[index] }
    internal var currentPhrase: String { return currentConversation.phrases[phraseIndex] }
    
    internal var isStartOfConversation: Bool { return phraseIndex == 0 }
    internal var isConversing: Bool {
        return phraseIndex > 0 && (phraseIndex <= (currentConversation.phrases.count - 1))
    }
    internal var personTalking: Person { return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser }
    
    private let conversations: [Conversation]
    private var index = 0
    private var phraseIndex = 0
    
    init(type: ConversationType) {
        self.type = type
        
        switch type {
        case .deciding:
            conversations = [Conversation(id: 1, phrases: ["What would you like to do? We can journal, dance, or I can tell you some jokes.", "Journal, Dance, Jokes"])]
        case .joking:
            conversations = Tool.load("knockKnockJokeData.json")
        default:
            conversations = Tool.load("knockKnockJokeData.json")
        }
        
        pickUpLastConversation()
    }
    
    private func pickUpLastConversation() {
        switch type {
        case .joking:
            // FIXME: Property should get set correctly for conversation type
            let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.conversationId)
            if let index = conversations.firstIndex(where: { $0.id == id }) {
                self.index = index
            }
        default:
            return
        }
    }
    
    // MARK: - Actions
    
    internal func startConversation() {
        // FIXME: Property should get set correctly for different conversation types
        Event.track(Constant.Event.conversationStarted, properties: [
            Constant.Event.Property.conversationId: currentConversation.id
          ])
    }
    
    internal func queueNextPhrase() {
        phraseIndex += 1
        
        if phraseIndex > (currentConversation.phrases.count - 1) {
            phraseIndex = 0
            queueNextConversation()
        }
    }
    
    internal func queueNextConversation() {
        index += 1
        
        if index > (conversations.count - 1) {
            index = 0
        }
        // FIXME: Property should get set correctly for conversation types
        UserDefaults.standard.set(conversations[index].id, forKey: Constant.UserDefault.conversationId)
    }
}
