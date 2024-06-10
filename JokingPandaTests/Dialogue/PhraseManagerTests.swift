//
//  PhraseManagerTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/8/24.
//

import XCTest
@testable import JokingPanda

final class PhraseManagerTests: XCTestCase {
    private var mockBotPhrases: [String]!
    private var mockUserPhrases: [String]!
    private var phraseManager: PhraseManager!

    override func setUpWithError() throws {
        let mockPhrases = ["Knock, knock.","Who's there?","Tank.","Tank who?","You’re welcome."]
        mockBotPhrases = stride(from: 0, to: mockPhrases.count, by: 2).map { mockPhrases[$0] }
        mockUserPhrases = stride(from: 1, to: mockPhrases.count, by: 2).map { mockPhrases[$0] }
        
        let mockDialogue = Dialogue(id: 1, phrases: mockPhrases)
        phraseManager = PhraseManager(dialogue: mockDialogue)
    }

    override func tearDownWithError() throws {
        phraseManager = nil
    }
    
    func test_initialization() {
        XCTAssertEqual(phraseManager.currentIndex, 0)
        XCTAssertEqual(phraseManager.lastPhraseUserSaid, "")
    }
    
    func test_moveOnInDialogueIfNeeded_withExpectedUserPhrase_shouldIncrementIndex() {
        var index = 0
        phraseManager.lastPhraseUserSaid = mockUserPhrases[index]
        phraseManager.moveOnInDialogueIfNeeded()
        
        index = 1
        XCTAssertEqual(phraseManager.currentIndex, index)
        XCTAssertEqual(phraseManager.getBotPhrase(), mockBotPhrases[index])
        phraseManager.lastPhraseUserSaid = mockUserPhrases[index]
        phraseManager.moveOnInDialogueIfNeeded()
        
        index = 2
        XCTAssertEqual(phraseManager.currentIndex, index)
        XCTAssertEqual(phraseManager.getBotPhrase(), mockBotPhrases[index])
    }
    
    func test_queueNextPhraseIfNeeded_withUnexpectedUserPhrase_shouldNotIncrementIndex() {
        var index = 0
        phraseManager.lastPhraseUserSaid = mockUserPhrases[index]
        phraseManager.moveOnInDialogueIfNeeded()
        
        index = 1
        phraseManager.lastPhraseUserSaid = "So unexpected!"
        phraseManager.moveOnInDialogueIfNeeded()
        
        // Index should not increment.
        XCTAssertEqual(phraseManager.currentIndex, index)
    }
}
