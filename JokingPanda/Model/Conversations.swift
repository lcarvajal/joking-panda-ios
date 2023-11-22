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
    internal var isConversing = false
    internal var personTalking: Person { return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser }
    
    private let conversations: [Conversation]
    private var index = 0
    private var phraseIndex = 0
    
    init(type: ConversationType) {
        self.type = type
        
        switch type {
        case .deciding:
            conversations = [Conversation(id: 1, phrases: ["What would you like to do?", "", "We can journal, dance, or listen to some jokes.", ""])]
        case .joking:
            conversations = Tool.load("knockKnockJokeData.json")
        case .dancing:
            conversations = [
                Conversation(id: 1, phrases: ["over the edge song"]),
                Conversation(id: 2, phrases: ["run home vox song"]),
                Conversation(id: 3, phrases: ["sublime song"]),
                Conversation(id: 4, phrases: ["ya mama song"])
            ]
        case .journaling:
            conversations = [Conversation(id: 1, phrases: ["While we're journaling, I'll write down what we're talking about so that you can take a look at our talk another day. How do you feel today?", "", "What have you been up to today?", "", "Anything else you want to add to your journal?", ""])]
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
        isConversing = true
        
        // FIXME: Property should get set correctly for different conversation types
        Event.track(Constant.Event.conversationStarted, properties: [
            Constant.Event.Property.conversationId: currentConversation.id
          ])
    }
    
    internal func stopConversation() {
        phraseIndex = 0
        isConversing = false
        queueNextConversation()
    }
    
    internal func queueNextPhrase() {
        phraseIndex += 1
        
        if phraseIndex > (currentConversation.phrases.count - 1) {
            stopConversation()
        }
    }
    
    private func queueNextConversation() {
        index += 1
        
        if index > (conversations.count - 1) {
            index = 0
        }
        
        switch type {
        case .joking:
            // FIXME: Property should get set correctly for conversation types
            UserDefaults.standard.set(conversations[index].id, forKey: Constant.UserDefault.conversationId)
        default:
            return
        }
    }
}
