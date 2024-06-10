//
//  DialogueManagerTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/8/24.
//

import XCTest
@testable import JokingPanda

final class DialogueManagerTests: XCTestCase {
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
        dialogueManager = nil
    }
    
    func test_startDialogue_shouldBeStartOfDialogue() {
        dialogueManager.startDialogue()
        XCTAssertTrue(dialogueManager.isStartOfDialogue)
        
        dialogueManager.startDialogue()
        dialogueManager.queueNextDialogue()
        dialogueManager.startDialogue()
        XCTAssertTrue(dialogueManager.isStartOfDialogue)
    }
    
    func test_moveOnInDialogueIfNeeded_withCorrectUserInput_shouldBeNextPhrase() {
        dialogueManager.startDialogue()
        XCTAssertEqual(dialogueManager.getBotPhrase(), mockDialogues[0].phrases[0])
        XCTAssertEqual(dialogueManager.getExpectedUserPhrase(), mockDialogues[0].phrases[1])
        
        dialogueManager.lastPhraseUserSaid = mockDialogues[0].phrases[1]
        dialogueManager.moveOnInDialogueIfNeeded()
        XCTAssertEqual(dialogueManager.getBotPhrase(), mockDialogues[0].phrases[2])
        XCTAssertEqual(dialogueManager.getExpectedUserPhrase(), mockDialogues[0].phrases[3])
        
        dialogueManager.lastPhraseUserSaid = mockDialogues[0].phrases[3]
        dialogueManager.moveOnInDialogueIfNeeded()
        XCTAssertEqual(dialogueManager.getBotPhrase(), mockDialogues[0].phrases[4])
    }
    
    func test_queueNextDialogue_shouldBeFirstPhraseInNextDialogue() {
        for mockDialogue in mockDialogues {
            dialogueManager.startDialogue()
            XCTAssertEqual(dialogueManager.getBotPhrase(), mockDialogue.phrases[0])
            dialogueManager.queueNextDialogue()
        }
        
        dialogueManager.startDialogue()
        XCTAssertEqual(dialogueManager.getBotPhrase(), mockDialogues[0].phrases[0])
    }
    
    func test_getBotResponse_withDynamicUserInput_shouldReturnDynamicResponse() {
        dialogueManager.startDialogue()
        dialogueManager.lastPhraseUserSaid = "What?" // Saying something not according to dialogue
        dialogueManager.moveOnInDialogueIfNeeded()
        XCTAssertEqual(dialogueManager.getBotPhrase(), ConstantPhrase.explainKnockKnock)
        
        dialogueManager.lastPhraseUserSaid = "Who's there?"
        dialogueManager.moveOnInDialogueIfNeeded()
        dialogueManager.lastPhraseUserSaid = "What?" // Saying something not according to dialogue
        dialogueManager.moveOnInDialogueIfNeeded()
        XCTAssertEqual(dialogueManager.getBotPhrase(), ConstantPhrase.couldYouRepeatWhatYouSaid)
    }
}
