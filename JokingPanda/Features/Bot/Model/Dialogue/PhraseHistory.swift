//
//  PhraseHistory.swift
//  JokingPanda
//

import Foundation

class PhraseHistory {
    internal var phraseHistory = ""
    
    internal func remember(_ phraseSaidOrHeard: String, expectedPhrase: String?, saidBy personTalking: Person) {
        let phrase: String
        
        if let expectedPhrase = expectedPhrase {
            phrase = interpret(phraseHeard: phraseSaidOrHeard, expectedPhrase: expectedPhrase)
        }
        else {
            phrase = phraseSaidOrHeard
        }
        
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
    
    internal func rememberLaughter(loudness: Int) {
        phraseHistory += "\n🗣️ Laugh score: \(loudness) / 5"
        // FIXME: - Add event tracking back
//        Event.track(Constant.Event.laughCaptured, properties: [
//            Constant.Event.Property.actId: stageManager.lastAct.id,
//            Constant.Event.Property.laughScore: loudness
//          ])
    }
    
    internal func getPhraseHistory() -> String {
        return phraseHistory
    }
    
    private func interpret(phraseHeard: String, expectedPhrase: String) -> String {
        return Tool.levenshtein(aStr: phraseHeard, bStr: expectedPhrase) < 5 ? expectedPhrase : phraseHeard
    }
}
