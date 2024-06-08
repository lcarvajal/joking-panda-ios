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
    private var lastPhraseSaidOrHeard: String
    private var lastPhraseWasExpected: Bool {
        if lastPhraseSaidOrHeard.isEmpty {
            return true
        }
        else {
            return Tool.levenshtein(aStr: lastPhraseSaidOrHeard, bStr: currentPhrase) < 7
        }
    }
    private var personWhoShouldSpeakPhrase: Person { return index % 2 == 0 ? Person.bot : Person.currentUser }
    
    internal var currentIndex: Int { return index }
    internal var currentPhrase: String { return phrases[index] }
    internal var noMorePhrasesToQueue: Bool { return index > (phrases.count - 1) }
    
    init(phrases: [String]){
        self.phrases = phrases
        
        self.index = 0
        self.lastPhraseSaidOrHeard = ""
    }
    
    internal func queueNextPhraseIfNeeded() {
        if lastPhraseWasExpected {
            index += 1
        }
        else {
            debugPrint("Not queing next line in dialogue since last phrase was not expected.")
        }
    }
    
    internal func getBotResponse() -> BotResponse {
        return BotResponse(userSaidSomethingExpected: lastPhraseWasExpected, nextPhraseInDialog: currentPhrase)
    }
}
