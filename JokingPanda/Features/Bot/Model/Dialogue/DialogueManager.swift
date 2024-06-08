//
//  DialogueManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/22/23.
//

import Foundation

class DialogueManager {
    internal var currentAct: Dialogue { return acts[actIndex] }
    internal var lastAct: Dialogue { return acts[actIndex - 1]}
    internal var lastPhraseSaidOrHeard = ""
    internal var currentLine: String { return currentAct.lines[lineIndex] }
    internal var previousLine: String? {
        if lineIndex > 0 {
            return currentAct.lines[lineIndex - 1]
        }
        else {
            return nil
        }
    }
    
    internal var isStartOfAct: Bool { return lineIndex == 0 }
    internal var isActing = false
    internal var personActing: Person { return lineIndex % 2 == 0 ? Person.bot : Person.currentUser }
    
    private let acts: [Dialogue]
    private var actIndex = 0
    private var lastPhraseExpected: Bool {
        if lastPhraseSaidOrHeard.isEmpty {
            return true
        }
        else {
            return Tool.levenshtein(aStr: lastPhraseSaidOrHeard, bStr: currentLine) < 7
        }
    }
    private var lineIndex = 0
    
    static func knockKnockJokesInstance() -> DialogueManager {
        let jokingActs: [Dialogue] = Tool.load(Constant.FileName.knockKnockJokesJSON, url: nil)
        return DialogueManager(acts: jokingActs)
    }
    
    init(acts: [Dialogue]) {
        self.acts = acts
        pickUpLastAct()
    }
    
    private func pickUpLastAct() {
        // FIXME: Property should get set correctly for conversation type
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.actId)
        if let index = acts.firstIndex(where: { $0.id == id }) {
            self.actIndex = index
        }
    }
    
    // MARK: - Actions
    
    internal func startDialogue() {
        isActing = true
        
        // FIXME: Property should get set correctly for different conversation types
        Event.track(Constant.Event.conversationStarted, properties: [
            Constant.Event.Property.actId: currentAct.id
          ])
    }
    
    internal func stopDialogue() {
        lineIndex = 0
        isActing = false
        lastPhraseSaidOrHeard = ""
        queueNextAct()
    }
    
    internal func queueNextLineIfNeeded() {
        if lastPhraseExpected {
            lineIndex += 1
            
            if lineIndex > (currentAct.lines.count - 1) {
                stopDialogue()
            }
        }
        else {
            debugPrint("Not queing next line in dialogue since last phrase was not expected.")
        }
    }
    
    private func queueNextAct() {
        actIndex += 1
        
        if actIndex > (acts.count - 1) {
            actIndex = 0
        }
        
        // FIXME: Property should get set correctly for conversation types
        UserDefaults.standard.set(acts[actIndex].id, forKey: Constant.UserDefault.actId)
    }
    
    internal func getCurrentPhrase() -> String {
        return currentLine
    }
    
    internal func getResponse() -> String? {
        if lastPhraseExpected && isActing {
            return currentLine
        }
        else if isActing {
            return getClarificationResponse()
        }
        else {
            return nil
        }
    }
    
    private func getClarificationResponse() -> String {
        switch currentLine {
        case ConstantLine.whosThere:
            return ConstantLine.explainKnockKnock
        default:
            return ConstantLine.couldYouRepeatWhatYouSaid
        }
    }
}
