//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//

import Foundation

class ConversationManager: NSObject, ObservableObject {
    @Published var history = ""
    @Published var type: ConversationType = .deciding
    
    internal var currentPhrase: String { return currentConversation.phrases[phraseIndex] }
    internal var isStartOfConversation: Bool { return phraseIndex == 0 }
    internal var isConversing: Bool { return phraseIndex <= (currentConversation.phrases.count - 1) }
    internal var personTalking: Person { return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser }
    
    private var currentConversation: Conversation { return knockKnockJokes[index] }
    private var index = 0
    private var phraseIndex = 0
    
    private let decidingConversations: [Conversation] = [Conversation(id: 1, phrases: ["What would you like to do? We can journal, dance, or I can tell you some jokes.", "Journal, Dance, Jokes"])]
    private let knockKnockJokes: [Conversation] = Tool.load("knockKnockJokeData.json")
    
    // MARK: - Setup
    
    init(type: ConversationType) {
        super.init()
        setIndexFromLastConversation()
    }
    
    private func setIndexFromLastConversation() {
        // FIXME: Property should get set correctly for conversation type
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.conversationId)
        if let index = knockKnockJokes.firstIndex(where: { $0.id == id }) {
            self.index = index
        }
    }
    
    // MARK: - Actions
    
    internal func startConversation() {
        if history != "" {
            history += "\n"
        }
        
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
    
    private func queueNextConversation() {
        index += 1
        
        if index > (knockKnockJokes.count - 1) {
            index = 0
        }
        // FIXME: Property should get set correctly for jokes
        UserDefaults.standard.set(knockKnockJokes[index].id, forKey: Constant.UserDefault.conversationId)
    }
    
    internal func updateConversationHistory(_ recognizedSpeech: String? = nil) {
        if history != "" {
            history += "\n"
        }
        
        var phraseToAdd = currentPhrase
        if let speech = recognizedSpeech {
            // Use recognized speech if it is very different from the current expected phrase
            phraseToAdd = Tool.levenshtein(aStr: speech, bStr: currentPhrase) < 5 ? currentPhrase : speech
        }
        
        switch personTalking {
        case .bot:
            history += "🐼 \(phraseToAdd)"
        case .currentUser:
            history += "🗣️ \(phraseToAdd)"
        }
    }
}
