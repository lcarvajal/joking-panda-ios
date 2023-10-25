//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation

struct ConversationManager {
    private var conversations: [Conversation] = load("conversationData.json")
    private var conversationIndex = 0
    private var phraseIndex = 0
    
    internal mutating func incrementPhraseIndex() {
        phraseIndex += 1
        
        if phraseIndex > (conversations[conversationIndex].phrases.count - 1) {
            phraseIndex = 0
            conversationIndex += 1
            
            if conversationIndex > (conversations.count - 1) {
                conversationIndex = 0
            }
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

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
