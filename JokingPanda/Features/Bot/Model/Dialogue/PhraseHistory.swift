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
    internal func addPhrase(_ phraseSaidOrHeard: String, expectedPhrase: String?, saidBy personTalking: Person) {
        let phrase: String
        
        if let expectedPhrase = expectedPhrase {
            phrase = getInterpretedPhrase(phraseHeard: phraseSaidOrHeard, expectedPhrase: expectedPhrase)
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
    
    /**
     Appends the loudness score with a description to `history` in a newline.
     */
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
    
    /**
     - returns: String interpreted phrase which returns the expected phrase when it closely matches the heard phrase.
     */
    private func getInterpretedPhrase(phraseHeard: String, expectedPhrase: String) -> String {
        return Tool.levenshtein(aStr: phraseHeard, bStr: expectedPhrase) < 5 ? expectedPhrase : phraseHeard
    }
}
