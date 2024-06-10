//
//  PhraseManagerTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/8/24.
//

import XCTest
@testable import JokingPanda

final class DialogueTests: XCTestCase {
    private var mockBotPhrases: [String]!
    private var mockUserPhrases: [String]!
    private var dialogue: Dialogue!

    override func setUpWithError() throws {
        let mockPhrases = ["Knock, knock.","Who's there?","Tank.","Tank who?","You’re welcome."]
        mockBotPhrases = stride(from: 0, to: mockPhrases.count, by: 2).map { mockPhrases[$0] }
        mockUserPhrases = stride(from: 1, to: mockPhrases.count, by: 2).map { mockPhrases[$0] }
        dialogue = Dialogue(id: 1, phrases: mockPhrases)
    }

    override func tearDownWithError() throws {
        mockBotPhrases = nil
        mockUserPhrases = nil
        dialogue = nil
    }
    
    func test_initialization() {
        XCTAssertEqual(dialogue.currentIndex, 0)
        XCTAssertEqual(dialogue.lastPhraseUserSaid, "")
    }
    
    func test_moveOnInDialogueIfNeeded_withExpectedUserPhrase_shouldIncrementIndex() {
        var index = 0
        dialogue.lastPhraseUserSaid = mockUserPhrases[index]
        dialogue.moveOnInDialogueIfNeeded()
        
        index = 1
        XCTAssertEqual(dialogue.currentIndex, index)
        XCTAssertEqual(dialogue.getCurrentBotPhrase(), mockBotPhrases[index])
        dialogue.lastPhraseUserSaid = mockUserPhrases[index]
        dialogue.moveOnInDialogueIfNeeded()
        
        index = 2
        XCTAssertEqual(dialogue.currentIndex, index)
        XCTAssertEqual(dialogue.getCurrentBotPhrase(), mockBotPhrases[index])
    }
    
    func test_queueNextPhraseIfNeeded_withUnexpectedUserPhrase_shouldNotIncrementIndex() {
        var index = 0
        dialogue.lastPhraseUserSaid = mockUserPhrases[index]
        dialogue.moveOnInDialogueIfNeeded()
        
        index = 1
        dialogue.lastPhraseUserSaid = "So unexpected!"
        dialogue.moveOnInDialogueIfNeeded()
        
        // Index should not increment.
        XCTAssertEqual(dialogue.currentIndex, index)
    }
    
    func test_queueNextPhraseIfNeeded_withUnexpectedUserPhrase_shouldGiveDynamicResponse() {
        dialogue.lastPhraseUserSaid = "So unexpected!"
        dialogue.moveOnInDialogueIfNeeded()
        XCTAssertEqual(dialogue.getCurrentBotPhrase(), ConstantPhrase.explainKnockKnock)
        
        dialogue.lastPhraseUserSaid = mockUserPhrases[0]
        dialogue.moveOnInDialogueIfNeeded()
        XCTAssertEqual(dialogue.getCurrentBotPhrase(), mockBotPhrases[1])
        
        dialogue.lastPhraseUserSaid = "So unexpected!"
        dialogue.moveOnInDialogueIfNeeded()
        XCTAssertEqual(dialogue.getCurrentBotPhrase(), ConstantPhrase.couldYouRepeatWhatYouSaid)
    }
}
