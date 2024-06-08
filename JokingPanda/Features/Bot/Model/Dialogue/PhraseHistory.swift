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
    
    internal func addPhrase(_ phraseSaidOrHeard: String, expectedPhrase: String?, saidBy personTalking: Person) {
        let phrase: String
        
        if let expectedPhrase = expectedPhrase {
            phrase = interpret(phraseHeard: phraseSaidOrHeard, expectedPhrase: expectedPhrase)
        }
        else {
            phrase = phraseSaidOrHeard
        }
        
        if history != "" {
            history += "\n"
        }
        
        switch personTalking {
        case .bot:
            history += "🐼 " + phrase
        case .currentUser:
            history += "🗣️ " + phrase
        }
    }
    
    internal func addLaughter(loudness: Int) {
        history += "\n🗣️ Laugh score: \(loudness) / 5"
        // FIXME: - Add event tracking back
//        Event.track(Constant.Event.laughCaptured, properties: [
//            Constant.Event.Property.actId: stageManager.lastAct.id,
//            Constant.Event.Property.laughScore: loudness
//          ])
    }
    
    internal func getHistory() -> String {
        return history
    }
    
    private func interpret(phraseHeard: String, expectedPhrase: String) -> String {
        return Tool.levenshtein(aStr: phraseHeard, bStr: expectedPhrase) < 5 ? expectedPhrase : phraseHeard
    }
}
