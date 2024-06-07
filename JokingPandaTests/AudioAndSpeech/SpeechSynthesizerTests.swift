//
//  SpeechSynthesizerTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/7/24.
//

import XCTest
import AVFoundation
@testable import JokingPanda

final class MockSpeechSynthesizerDelegate: SpeechSynthesizerDelegate {
    internal var phrase: String = ""
    internal var error: Error? = nil
    
    private var expectation: XCTestExpectation?
    private let testCase: XCTestCase
    
    init(testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    internal func expectPhraseToBeSaid() {
        expectation = testCase.expectation(description: "Expect phrase to be said")
    }
    
    // MARK: - SpeechSynthesizer delegate methods
    
    func speechSynthesizerIsSayingPhrase(_ phrase: String) {
        if expectation != nil {
            self.phrase = phrase
        }
        expectation?.fulfill()
        expectation = nil
    }
    
    func speechSynthesizerDidSayPhrase(_ phrase: String) {
        if expectation != nil {
            self.phrase = phrase
        }
        expectation?.fulfill()
        expectation = nil
    }
    
    func speechSynthesizerErrorDidOccur(error: Error) {
        if expectation != nil {
            self.error = error
        }
        expectation?.fulfill()
        expectation = nil
    }
}

final class SpeechSynthesizerTests: XCTestCase {
    private var speechSynthesizer: SpeechSynthesizer!
    private var mockDelegate: MockSpeechSynthesizerDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()
        speechSynthesizer = SpeechSynthesizer()
        mockDelegate = MockSpeechSynthesizerDelegate(testCase: self)
        speechSynthesizer.delegate = mockDelegate
    }

    override func tearDownWithError() throws {
        speechSynthesizer = nil
        mockDelegate = nil
        try super.tearDownWithError()
    }

    func test_speechSynthesizer_initialization_shouldNotBeNil() throws {
        XCTAssertNotNil(speechSynthesizer)
        XCTAssertNotNil(speechSynthesizer.delegate)
    }

    func test_speechSynthesizer_withPhrase_ShouldBeEqual() throws {
        mockDelegate.expectPhraseToBeSaid()
        speechSynthesizer.speak(phrase: "Hello")
        
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertEqual(mockDelegate.phrase, "Hello")
    }
}
