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
    private let dialogues: [Dialogue]
    private var dialogueIndex = 0
    private var isDialogging = false
    private var phraseManager: PhraseManager?
    
    internal var isStartOfDialogue: Bool { return phraseManager?.currentIndex == 0 }
    
    static func knockKnockJokesInstance() -> DialogueManager {
        let jokingActs: [Dialogue] = Tool.load(Constant.FileName.knockKnockJokesJSON, url: nil)
        return DialogueManager(dialogues: jokingActs)
    }
    
    init(dialogues: [Dialogue]) {
        self.dialogues = dialogues
        pickUpLastDialogueFromUserDefaults()
    }
    
    internal func startDialogue() {
        isDialogging = true
        phraseManager = PhraseManager(phrases: currentDialogue.phrases)
        
        Event.track(Constant.Event.conversationStarted, properties: [
            Constant.Event.Property.actId: currentDialogue.id
        ])
    }
    
    internal func stopDialogue() {
        isDialogging = false
        queueNextDialogue()
    }
    
    internal func queueNextPhraseIfNeeded() {
        guard let phraseManager = phraseManager else { return }
        
        phraseManager.queueNextPhraseIfNeeded()
        if phraseManager.noMorePhrasesToQueue {
            stopDialogue()
        }
    }
    
    internal func getCurrentPhrase() -> String {
        guard let phraseManager = phraseManager else { return "" }
        return phraseManager.currentPhrase
    }
    
    internal func getBotResponsePhrase() -> String? {
        guard let phraseManager = phraseManager, isDialogging else { return nil }
        
        let botResponse = phraseManager.getBotResponse()
        return botResponse.phrase
    }
    
    // MARK: - Private
    
    private func pickUpLastDialogueFromUserDefaults() {
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.actId)
        if let index = dialogues.firstIndex(where: { $0.id == id }) {
            self.dialogueIndex = index
        }
    }
    
    private func queueNextDialogue() {
        dialogueIndex += 1
        
        if dialogueIndex > (dialogues.count - 1) {
            dialogueIndex = 0
        }
        
        UserDefaults.standard.set(dialogues[dialogueIndex].id, forKey: Constant.UserDefault.actId)
    }
}
