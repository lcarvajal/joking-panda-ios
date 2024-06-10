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
    private var isLastUserPhraseExpected: Bool
    
    internal var currentIndex: Int { return index }
    internal var lastPhraseUserSaid: String
    internal var noMorePhrasesInDialogue: Bool {
        return dialogue.getPhrase(for: .bot, index: index) == nil
    }
    
    init(dialogue: Dialogue){
        self.dialogue = dialogue
        self.index = 0
        self.isLastUserPhraseExpected = true
        self.lastPhraseUserSaid = ""
    }

    internal func moveOnInDialogueIfNeeded() {
        guard let expectedUserPhrase = dialogue.getPhrase(for: .currentUser, index: index) else {
            return
        }
        
        isLastUserPhraseExpected = isPhraseExpected(phraseSaid: lastPhraseUserSaid, expectedPhrase: expectedUserPhrase)
        if isLastUserPhraseExpected {
            index += 1
        }
        else {
            debugPrint("Not queing next phrase in dialogue since last phrase was not expected.")
        }
    }
    
    internal func getBotPhrase() -> String? {
        guard let botPhrase = dialogue.getPhrase(for: .bot, index: index) else {
            return nil
        }
        
        if isLastUserPhraseExpected {
            return botPhrase
        }
        else {
            guard let expectedUserPhrase = dialogue.getPhrase(for: .currentUser, index: index) else {
                return botPhrase
            }
            let botResponse = BotResponse(userPhraseWasExpected: isLastUserPhraseExpected, expectedUserPhrase: expectedUserPhrase, nextBotPhrase: botPhrase)
            return botResponse.phrase
        }
    }
    
    internal func getExpectedUserPhrase() -> String? {
        return dialogue.getPhrase(for: .currentUser, index: index)
    }
    
    private func isPhraseExpected(phraseSaid: String, expectedPhrase: String) -> Bool {
        return Tool.levenshtein(aStr: phraseSaid, bStr: expectedPhrase) < 7
    }
}
