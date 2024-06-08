//
//  DialogueTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/8/24.
//

import XCTest
@testable import JokingPanda

final class DialogueTests: XCTestCase {
    private var mockDialogues: [Dialogue]!
    private var dialogueManager: DialogueManager!

    override func setUpWithError() throws {
        mockDialogues = [
            Dialogue(id: 1, phrases: ["Knock, knock.","Who's there?","Tank.","Tank who?","You’re welcome."]),
            Dialogue(id: 2, phrases: ["Kick, kick.","Who's there?","A panda with his arms full of bamboo!"]),
            Dialogue(id: 3, phrases: ["Knock, knock.","Who's there?","Heidi.","Heidi who?","Heidi 'cided to come over to play!"])
        ]
        
        dialogueManager = DialogueManager(dialogues: mockDialogues)
    }

    override func tearDownWithError() throws {
        mockDialogues = nil
        dialogueManager.stopDialogue()
        dialogueManager = nil
    }
    
    func test_startDialogue_shouldBeStartOfDialogue() {
        dialogueManager.startDialogue()
        XCTAssertTrue(dialogueManager.isStartOfDialogue)
        
        dialogueManager.startDialogue()
        dialogueManager.stopDialogue()
        dialogueManager.queueNextDialogue()
        dialogueManager.startDialogue()
        XCTAssertTrue(dialogueManager.isStartOfDialogue)
    }
    
    func test_queueNextPhrase_shouldBeNextPhraseInPhrases() {
        dialogueManager.startDialogue()
        XCTAssertEqual(dialogueManager.getCurrentPhrase(), mockDialogues[0].phrases[0])
        
        dialogueManager.queueNextPhraseIfNeeded()
        XCTAssertEqual(dialogueManager.getCurrentPhrase(), mockDialogues[0].phrases[1])
        
        dialogueManager.queueNextDialogue()
        dialogueManager.startDialogue()
        XCTAssertEqual(dialogueManager.getCurrentPhrase(), mockDialogues[1].phrases[0])
        
        dialogueManager.queueNextPhraseIfNeeded()
        dialogueManager.queueNextPhraseIfNeeded()
        XCTAssertEqual(dialogueManager.getCurrentPhrase(), mockDialogues[1].phrases[2])
    }
    
    func test_queueNextDialogue_shouldUpdateCurrentPhraseFromNextDialogue() {
        for mockDialogue in mockDialogues {
            dialogueManager.startDialogue()
            XCTAssertEqual(dialogueManager.getCurrentPhrase(), mockDialogue.phrases[0])
            dialogueManager.stopDialogue()
            dialogueManager.queueNextDialogue()
        }
        
        dialogueManager.startDialogue()
        XCTAssertEqual(dialogueManager.getCurrentPhrase(), mockDialogues[0].phrases[0])
    }
    
    func test_getBotResponse_withDynamicUserInput_shouldReturnDynamicResponse() {
        dialogueManager.startDialogue()
        dialogueManager.queueNextPhraseIfNeeded() // User
        dialogueManager.lastPhraseUserSaid = "What?" // Saying something not according to dialogue
        XCTAssertEqual(dialogueManager.getBotResponsePhrase(), ConstantPhrase.explainKnockKnock)
        
        dialogueManager.lastPhraseUserSaid = "Who's there?"
        dialogueManager.queueNextPhraseIfNeeded() // Bot
        dialogueManager.queueNextPhraseIfNeeded() // User
        dialogueManager.lastPhraseUserSaid = "What?" // Saying something not according to dialogue
        XCTAssertEqual(dialogueManager.getBotResponsePhrase(), ConstantPhrase.couldYouRepeatWhatYouSaid)
    }
}
