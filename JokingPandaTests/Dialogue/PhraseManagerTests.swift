//
//  PhraseManagerTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/8/24.
//

import XCTest
@testable import JokingPanda

final class PhraseManagerTests: XCTestCase {
    private var mockPhrases: [String]!
    private var phraseManager: PhraseManager!

    override func setUpWithError() throws {
        mockPhrases = ["Knock, knock.","Who's there?","Tank.","Tank who?","You’re welcome."]
        phraseManager = PhraseManager(phrases: mockPhrases)
    }

    override func tearDownWithError() throws {
        phraseManager = nil
    }
    
    func test_initialization() {
        XCTAssertEqual(phraseManager.currentIndex, 0)
        XCTAssertEqual(phraseManager.lastPhraseUserSaid, "")
    }
    
    func test_queueNextPhraseIfNeeded_withExpectedPhrase_shouldIncrementIndex() {
        phraseManager.queueNextPhraseIfNeeded()
        XCTAssertEqual(phraseManager.currentIndex, 1)
        phraseManager.lastPhraseUserSaid = mockPhrases[2]
        phraseManager.queueNextPhraseIfNeeded()
        XCTAssertEqual(phraseManager.currentIndex, 2)
    }
    
    func test_queueNextPhraseIfNeeded_withUnexpectedPhrase_shouldNotIncrementIndex() {
        phraseManager.queueNextPhraseIfNeeded()
        phraseManager.lastPhraseUserSaid = "So unexpected!"
        phraseManager.queueNextPhraseIfNeeded()
        XCTAssertEqual(phraseManager.currentIndex, 1)
    }
}
