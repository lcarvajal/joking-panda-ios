//
//  Brain.swift
//  JokingPanda
//

import Foundation

class Brain: NSObject, ObservableObject {
    @Published var phraseHistory = ""
    
    internal func interpret(phraseHeard: String, phraseExpected: String) -> String {
        return Tool.levenshtein(aStr: phraseHeard, bStr: phraseExpected) < 5 ? phraseExpected : phraseHeard
    }
    
    internal func remember(_ phrase: String, saidBy personTalking: Person) {
        if phraseHistory != "" {
            phraseHistory += "\n"
        }
        
        switch personTalking {
        case .bot:
            phraseHistory += "🐼 " + phrase
        case .currentUser:
            phraseHistory += "🗣️ " + phrase
        }
    }
    
    internal func getResponsePhrase(for phraseHeard: String?) -> String? {
        
        return ""
    }
}
