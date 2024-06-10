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
    private var currentDialogue: Dialogue
    private let dialogues: [Dialogue]
    private var index = 0
    
    internal var lastPhraseUserSaid: String = "" {
        didSet {
            currentDialogue.lastPhraseUserSaid = lastPhraseUserSaid
        }
    }
    
    /**
     - returns: DialogueManager containing knock-knock jokes.
     */
    static func knockKnockJokesInstance() -> DialogueManager {
        let jokeDialogues: [Dialogue] = Tool.load(Constant.FileName.knockKnockJokesJSON, url: nil)
        return DialogueManager(dialogues: jokeDialogues)
    }
    
    init(dialogues: [Dialogue]) {
        self.dialogues = dialogues
        self.currentDialogue = dialogues[index]
    }
    
    /**
     Instantiates a new `currentDialogue` object which tracks the current phrase as a user moves along in a dialogue.
     */
    internal func startDialogue() {
        Event.track(Constant.Event.conversationStarted, properties: [
            Constant.Event.Property.actId: currentDialogue.id
        ])
    }
    
    /**
     Moves on to next dialogue index if available. If not, sets index to `0`.
     */
    internal func queueNextDialogue() {
        index += 1
        
        if index > (dialogues.count - 1) {
            index = 0
        }
        
        currentDialogue = dialogues[index]
        UserDefaults.standard.set(currentDialogue.id, forKey: Constant.UserDefault.actId)
    }
    
    /**
     Moves on to the next phrase within the dialogue.
     */
    internal func moveOnInDialogueIfNeeded() {
        currentDialogue.incrementIndexIfLastUserPhraseExpected()
    }
    
    /**
     - returns: String current phrase in current dialogue.
     */
    internal func getExpectedUserPhrase() -> String? {
        return currentDialogue.getCurrentUserPhrase()
    }
    
    /**
     - returns: String bot response phrase if user says something that strays from current dialogue.
     */
    internal func getBotPhrase() -> String? {
        return currentDialogue.getCurrentBotPhrase()
    }
    
    /**
     Picks up index from last dialogue heard so that a user doesn't have to start from the beginning.
     */
    internal func pickUpLastDialogueFromUserDefaults() {
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.actId)
        if let index = dialogues.firstIndex(where: { $0.id == id }) {
            self.index = index
            self.currentDialogue = self.dialogues[self.index]
        }
    }
}
