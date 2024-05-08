//
//  Brain.swift
//  JokingPanda
//

import Foundation

class Brain {
    internal var phraseHistory = ""
    internal var wantsToStartNewJoke: Bool {
        return stageManager.isStartOfAct
    }
    
    private let stageManager: StageManager = StageManager()
    private var lastPhrase = ""
    private var lastPhraseWasExpected = true
    
    private func interpret(phraseHeard: String) -> String {
        let expectedPhrase = stageManager.currentLine
        return Tool.levenshtein(aStr: phraseHeard, bStr: expectedPhrase) < 5 ? expectedPhrase : phraseHeard
    }
    
    internal func remember(_ phrase: String, saidBy personTalking: Person) {
        let interpretedPhrase = interpret(phraseHeard: phrase)
        
        if phraseHistory != "" {
            phraseHistory += "\n"
        }
        
        switch personTalking {
        case .bot:
            phraseHistory += "🐼 " + interpretedPhrase
        case .currentUser:
            phraseHistory += "🗣️ " + interpretedPhrase
        }
        
        lastPhrase = interpretedPhrase
        lastPhraseWasExpected = (Tool.levenshtein(aStr: interpretedPhrase, bStr: stageManager.currentLine) < 2)
        
        if lastPhraseWasExpected {
            stageManager.queueNextLine()
        }
    }
    
    internal func getInitalPhrase() -> String {
        return stageManager.currentLine
    }
    
    internal func getExpectedUserResponse() -> String {
        return stageManager.currentLine
    }
    
    internal func getPhraseHistory() -> String {
        return phraseHistory
    }
    
    internal func startConversation() {
        stageManager.startAct()
    }
    
    internal func stopConversation() {
        stageManager.stopAct()
    }
    
    internal func getResponse() -> String? {
        if lastPhraseWasExpected && stageManager.isRunningAnAct {
            return stageManager.currentLine
        }
        else if stageManager.isRunningAnAct {
            return getClarificationResponse()
        }
        else {
            return nil
        }
    }
    
    private func getClarificationResponse() -> String {
        switch stageManager.currentLine {
        case "Who’s there?":
            return "Let's try that again. When I say 'Knock, knock.' you say 'Who's there'? Knock knock."
        default:
            return "I'm sorry, could you say that again?"
        }
    }
}
