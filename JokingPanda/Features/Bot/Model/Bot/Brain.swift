//
//  Brain.swift
//  JokingPanda
//

import Foundation

class Brain {
    internal var phraseHistory = ""
    
    private let stageManager: StageManager = StageManager()
    
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
    
    internal func getInitalPhrase() -> String {
        return stageManager.currentLine
    }
    
    internal func getResponsePhrase(for phraseHeard: String?) -> String? {
        if stageManager.isRunningAnAct {
            return stageManager.currentLine
        }
        else {
            return nil
        }
    }
    
    internal func getPhraseHistory() -> String {
        return phraseHistory
    }
    
    internal func startConversation() {
        stageManager.startAct()
    }
    
    internal func moveOnInConversation() {
        stageManager.queueNextLine()
    }
    
    internal func stopConversation() {
        stageManager.stopAct()
    }
}
