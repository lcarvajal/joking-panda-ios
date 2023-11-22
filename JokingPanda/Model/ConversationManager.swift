//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//

import Foundation

class ConversationManager: NSObject, ObservableObject {
    @Published var history = ""
    @Published var selectedType: ConversationType = .deciding
    
    internal var currentConversations: Conversations { return conversations[selectedType]! }
    internal var currentPhrase: String { return currentConversations.currentPhrase }
    internal var isStartOfConversation: Bool { return currentConversations.isStartOfConversation }
    internal var isConversing: Bool { return currentConversations.isConversing }
    internal var personTalking: Person { return currentConversations.personTalking }
    
    private let conversations: [ConversationType: Conversations] = [
        .deciding : Conversations(type: .deciding),
        .joking: Conversations(type: .joking),
        .dancing: Conversations(type: .dancing),
        .journaling: Conversations(type: .journaling)
    ]
    private var phraseHistory: [String] = []
    
    // MARK: - Setup
    
    // MARK: - Actions
    
    internal func startConversation(type: ConversationType) {
        selectedType = type
        
        if history != "" {
            history += "\n"
        }
        
        currentConversations.startConversation()
    }
    
    internal func queueNextPhrase() {
        if currentConversations.personTalking == .currentUser,
           let lastPhrase = phraseHistory.last,
           let trigger = getConversationShiftTrigger(phrase: lastPhrase),
           trigger != selectedType {
            currentConversations.queueNextPhrase()
            selectedType = trigger
        }
        else {
            currentConversations.queueNextPhrase()
        }
    }
    
    private func getConversationShiftTrigger(phrase: String) -> ConversationType? {
        let phraseToCheck = phrase.lowercased()
        
        if phrase.lowercased().contains("joke") {
            return .joking
        }
        else {
            return nil
        }
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
        phraseHistory.append(phraseToAdd)
        
        switch personTalking {
        case .bot:
            phraseToAdd = "🐼 " + phraseToAdd
        case .currentUser:
            phraseToAdd = "🗣️ " + phraseToAdd
        }
        
        history += phraseToAdd
    }
}
