//
//  DialogueManager.swift
//  JokingPanda
//
/**
 Keeps track of the current phrase within a dialogue as well as the current dialogue in an array of dialogues.
 */

import Foundation

class DialogueManager {
    private var currentDialogue: Dialogue { return dialogues[dialogueIndex] }
    private var isDialogging = false
    private let dialogues: [Dialogue]
    private var dialogueIndex = 0
    
    private var currentPhrase: String { return currentDialogue.phrases[phraseIndex] }
    private var lastPhraseSaidOrHeard = ""
    private var lastPhraseExpected: Bool {
        if lastPhraseSaidOrHeard.isEmpty {
            return true
        }
        else {
            return Tool.levenshtein(aStr: lastPhraseSaidOrHeard, bStr: currentPhrase) < 7
        }
    }
    private var phraseIndex = 0
    
    internal var isStartOfDialogue: Bool { return phraseIndex == 0 }
    internal var personWhoShouldSpeakPhrase: Person { return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser }
    
    
    static func knockKnockJokesInstance() -> DialogueManager {
        let jokingActs: [Dialogue] = Tool.load(Constant.FileName.knockKnockJokesJSON, url: nil)
        return DialogueManager(dialogues: jokingActs)
    }
    
    init(dialogues: [Dialogue]) {
        self.dialogues = dialogues
        pickUpLastAct()
    }
    
    private func pickUpLastAct() {
        // FIXME: Property should get set correctly for conversation type
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.actId)
        if let index = dialogues.firstIndex(where: { $0.id == id }) {
            self.dialogueIndex = index
        }
    }
    
    // MARK: - Actions
    
    internal func startDialogue() {
        isDialogging = true
        
        // FIXME: Property should get set correctly for different conversation types
        Event.track(Constant.Event.conversationStarted, properties: [
            Constant.Event.Property.actId: currentDialogue.id
          ])
    }
    
    internal func stopDialogue() {
        phraseIndex = 0
        isDialogging = false
        lastPhraseSaidOrHeard = ""
        queueNextAct()
    }
    
    internal func queueNextLineIfNeeded() {
        if lastPhraseExpected {
            phraseIndex += 1
            
            if phraseIndex > (currentDialogue.phrases.count - 1) {
                stopDialogue()
            }
        }
        else {
            debugPrint("Not queing next line in dialogue since last phrase was not expected.")
        }
    }
    
    private func queueNextAct() {
        dialogueIndex += 1
        
        if dialogueIndex > (dialogues.count - 1) {
            dialogueIndex = 0
        }
        
        // FIXME: Property should get set correctly for conversation types
        UserDefaults.standard.set(dialogues[dialogueIndex].id, forKey: Constant.UserDefault.actId)
    }
    
    internal func getCurrentPhrase() -> String {
        return currentPhrase
    }
    
    internal func getResponse() -> String? {
        if lastPhraseExpected && isDialogging {
            return currentPhrase
        }
        else if isDialogging {
            return getClarificationResponse()
        }
        else {
            return nil
        }
    }
    
    private func getClarificationResponse() -> String {
        switch currentPhrase {
        case ConstantLine.whosThere:
            return ConstantLine.explainKnockKnock
        default:
            return ConstantLine.couldYouRepeatWhatYouSaid
        }
    }
}
