//
//  PhraseManager.swift
//  JokingPanda
//
/**
 Keeps track of the `index` for an array of `phrases`. 
 */

import Foundation

class PhraseManager {
    private let dialogue: Dialogue
    private var index: Int
    
    internal var currentIndex: Int { return index }
    internal var lastPhraseUserSaid: String
    internal var noMorePhrasesInDialogue: Bool {
        return dialogue.getPhrase(for: .bot, index: index) == nil
    }
    
    init(dialogue: Dialogue){
        self.dialogue = dialogue
        self.index = 0
        self.lastPhraseUserSaid = ""
    }

    internal func moveOnInDialogueIfNeeded() {
        guard let expectedUserPhrase = dialogue.getPhrase(for: .currentUser, index: index) else {
            debugPrint("unable to retrieve phrase for user")
            return }
        
        print("expected user phrase: \(expectedUserPhrase)")
        print("last phrase user said: \(lastPhraseUserSaid)")
        
        let isUserPhraseExpected = isPhraseExpected(phraseSaid: lastPhraseUserSaid, expectedPhrase: expectedUserPhrase)
        if isUserPhraseExpected {
            index += 1
        }
        else {
            debugPrint("Not queing next phrase in dialogue since last phrase was not expected.")
        }
    }
    
    internal func getBotPhrase() -> String? {
        dialogue.getPhrase(for: .bot, index: index)
    }
    
    internal func getExpectedUserPhrase() -> String? {
        return dialogue.getPhrase(for: .currentUser, index: index)
    }
    
    private func isPhraseExpected(phraseSaid: String, expectedPhrase: String) -> Bool {
        return Tool.levenshtein(aStr: phraseSaid, bStr: expectedPhrase) < 7
    }
}
