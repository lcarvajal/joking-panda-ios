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
    private var botPhrases: [String]
    private var userPhrases: [String]
    
    internal var currentIndex: Int { return index }
    internal var lastPhraseUserSaid: String
    internal var noMorePhrasesInDialogue: Bool { return index > (botPhrases.count - 1) }
    
    init(phrases: [String]){
        self.botPhrases = stride(from: 0, to: phrases.count, by: 2).map { phrases[$0] }
        self.userPhrases = stride(from: 1, to: phrases.count, by: 2).map { phrases[$0] }
        self.index = 0
        self.lastPhraseUserSaid = ""
    }
    
    internal func moveOnInDialogueIfNeeded() {
        let phraseExpected = isPhraseExpected(phraseSaid: lastPhraseUserSaid, expectedPhrase: userPhrases[index])
        if phraseExpected {
            index += 1
        }
        else {
            debugPrint("Not queing next phrase in dialogue since last phrase was not expected.")
        }
    }
    
    internal func getBotPhrase() -> BotResponse {
        if index == 0 {
            // Start of dialogue
            return BotResponse(userSaidSomethingExpected: true, nextPhraseInDialog: botPhrases[index])
        }
        else {
            let lastPhraseExpected = isPhraseExpected(phraseSaid: lastPhraseUserSaid, expectedPhrase: userPhrases[index - 1])
            return BotResponse(userSaidSomethingExpected: lastPhraseExpected, nextPhraseInDialog: botPhrases[index])
        }
    }
    
    internal func getExpectedUserPhrase() -> String? {
        return index < userPhrases.count ? userPhrases[index] : nil
    }
    
    private func isPhraseExpected(phraseSaid: String, expectedPhrase: String) -> Bool {
        return Tool.levenshtein(aStr: phraseSaid, bStr: expectedPhrase) < 7
    }
}
