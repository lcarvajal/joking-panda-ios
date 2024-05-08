//
//  Conversations.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/22/23.
//

import Foundation

class Play {
    internal let type: ActType
    internal var currentAct: Act { return acts[index] }
    internal var currentLine: String { return currentAct.phrases[phraseIndex] }
    
    internal var isStartOfAct: Bool { return phraseIndex == 0 }
    internal var isActing = false
    internal var personActing: Person { return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser }
    
    private let acts: [Act]
    private var index = 0
    private var phraseIndex = 0
    
    init(type: ActType) {
        self.type = type
        
        switch type {
        case .deciding:
            acts = [Act(id: 1, phrases: ["What would you like to do?", "", "We can dance or listen to some jokes.", ""])]
        case .joking:
            acts = Tool.load("knockKnockJokeData.json")
        }
        
        pickUpLastConversation()
    }
    
    private func pickUpLastConversation() {
        switch type {
        case .joking:
            // FIXME: Property should get set correctly for conversation type
            let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.conversationId)
            if let index = acts.firstIndex(where: { $0.id == id }) {
                self.index = index
            }
        default:
            return
        }
    }
    
    // MARK: - Actions
    
    internal func startConversation() {
        isActing = true
        
        // FIXME: Property should get set correctly for different conversation types
        Event.track(Constant.Event.conversationStarted, properties: [
            Constant.Event.Property.conversationId: currentAct.id
          ])
    }
    
    internal func stopConversation() {
        phraseIndex = 0
        isActing = false
        queueNextConversation()
    }
    
    internal func queueNextPhrase() {
        phraseIndex += 1
        
        if phraseIndex > (currentAct.phrases.count - 1) {
            stopConversation()
        }
    }
    
    private func queueNextConversation() {
        index += 1
        
        if index > (acts.count - 1) {
            index = 0
        }
        
        switch type {
        case .joking:
            // FIXME: Property should get set correctly for conversation types
            UserDefaults.standard.set(acts[index].id, forKey: Constant.UserDefault.conversationId)
        default:
            return
        }
    }
}
