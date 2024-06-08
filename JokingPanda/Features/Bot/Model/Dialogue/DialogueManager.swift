//
//  DialogueManager.swift
//  JokingPanda
//
/**
 Manages which phrase to say/expect with a `dialogues` array.
 Uses `index` to keep track of the current dialogue in use.
 Uses`phraseManager` to manage the phrases within the current dialogue.
 */

import Foundation

class DialogueManager {
    private var currentDialogue: Dialogue { return dialogues[index] }
    private let dialogues: [Dialogue]
    private var index = 0
    private var isDialogging = false
    private var phraseManager: PhraseManager?
    
    internal var isStartOfDialogue: Bool { return phraseManager?.currentIndex == 0 }
    
    /**
     - returns: DialogueManager containing knock-knock jokes.
     */
    static func knockKnockJokesInstance() -> DialogueManager {
        let jokeDialogues: [Dialogue] = Tool.load(Constant.FileName.knockKnockJokesJSON, url: nil)
        return DialogueManager(dialogues: jokeDialogues)
    }
    
    init(dialogues: [Dialogue]) {
        self.dialogues = dialogues
        pickUpLastDialogueFromUserDefaults()
    }
    
    /**
     Instantiates a new `PhraseManager` object which tracks the current phrase as a user moves along in a dialogue.
     */
    internal func startDialogue() {
        isDialogging = true
        phraseManager = PhraseManager(phrases: currentDialogue.phrases)
        
        Event.track(Constant.Event.conversationStarted, properties: [
            Constant.Event.Property.actId: currentDialogue.id
        ])
    }
    
    /**
     Cleans up properties.
     */
    internal func stopDialogue() {
        isDialogging = false
        phraseManager = nil
    }
    
    /**
     Moves on to next dialogue index if available. If not, sets index to `0`.
     */
    internal func queueNextDialogue() {
        index += 1
        
        if index > (dialogues.count - 1) {
            index = 0
        }
        
        UserDefaults.standard.set(dialogues[index].id, forKey: Constant.UserDefault.actId)
    }
    
    /**
     Moves on to the next phrase within the dialogue.
     */
    internal func queueNextPhraseIfNeeded() {
        guard let phraseManager = phraseManager else { return }
        
        phraseManager.queueNextPhraseIfNeeded()
        if phraseManager.noMorePhrasesToQueue {
            stopDialogue()
        }
    }
    
    /**
     - returns: String current phrase in current dialogue.
     */
    internal func getCurrentPhrase() -> String {
        guard let phraseManager = phraseManager else { return "" }
        return phraseManager.currentPhrase
    }
    
    /**
     - returns: String bot response phrase if user says something that strays from current dialogue.
     */
    internal func getBotResponsePhrase() -> String? {
        guard let phraseManager = phraseManager, isDialogging else { return nil }
        
        let botResponse = phraseManager.getBotResponse()
        return botResponse.phrase
    }
    
    internal func pickUpLastDialogueFromUserDefaults() {
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.actId)
        if let index = dialogues.firstIndex(where: { $0.id == id }) {
            self.index = index
        }
    }
}
