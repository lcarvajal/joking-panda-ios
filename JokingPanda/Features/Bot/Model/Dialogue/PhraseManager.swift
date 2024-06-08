//
//  PhraseManager.swift
//  JokingPanda
//
/**
 Keeps track of the `index` for an array of `phrases`. 
 */

import Foundation

class PhraseManager {
    private var index: Int
    private var phrases: [String]
    private var lastPhraseWasExpected: Bool {
        if lastPhraseUserSaid.isEmpty {
            return true
        }
        else {
            return Tool.levenshtein(aStr: lastPhraseUserSaid, bStr: currentPhrase) < 7
        }
    }
    private var personSayingPhrase: Person { return index % 2 == 0 ? Person.bot : Person.currentUser }
    
    internal var currentIndex: Int { return index }
    internal var currentPhrase: String { return phrases[index] }
    internal var lastPhraseUserSaid: String
    internal var noMorePhrasesToQueue: Bool { return index > (phrases.count - 1) }
    
    init(phrases: [String]){
        self.phrases = phrases
        
        self.index = 0
        self.lastPhraseUserSaid = ""
    }
    
    internal func queueNextPhraseIfNeeded() {
        if personSayingPhrase == .currentUser && !lastPhraseWasExpected {
            debugPrint("Not queing next phrase in dialogue since last phrase was not expected.")
        }
        else {
            index += 1
        }
    }
    
    internal func getBotResponse() -> BotResponse {
        return BotResponse(userSaidSomethingExpected: lastPhraseWasExpected, nextPhraseInDialog: currentPhrase)
    }
}
