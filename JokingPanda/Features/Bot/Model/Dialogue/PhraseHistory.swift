//
//  PhraseHistory.swift
//  JokingPanda
//
/**
 Keeps track of the phrases said or heard in `phraseHistory`.
 */

import Foundation

class PhraseHistory {
    internal var history = ""
    
    /**
     Appends a phrase to `history` in a newline.
     If the phrase is close to what is expected, the expected phrase gets appended instead of what was actually heard.
     */
    internal func addPhrase(_ phraseSaidOrHeard: String, saidBy personTalking: Person) {
        if history != "" {
            history += "\n"
        }
        
        switch personTalking {
        case .bot:
            history += "🐼 " + phraseSaidOrHeard
        case .currentUser:
            history += "🗣️ " + phraseSaidOrHeard
        }
    }
    
    internal func getHistory() -> String {
        return history
    }
}
