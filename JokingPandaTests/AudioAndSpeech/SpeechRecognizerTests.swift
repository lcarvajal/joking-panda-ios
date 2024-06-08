//
//  SpeechRecognizerTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/7/24.
//

import XCTest
import Speech
@testable import JokingPanda

final class MockSpeechRecognizerDelegate: SpeechRecognizerDelegate {
    internal var recognizedPhrase: String = ""
    internal var error: Error? = nil
    
    private var expectation: XCTestExpectation?
    private let testCase: XCTestCase
    
    init(testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    internal func expectPhraseRecognition() {
        expectation = testCase.expectation(description: "Expect phrase to be recognized")
    }
    
    func speechRecognizerIsRecognizing(_ phrase: String) {
        if expectation != nil {
            self.recognizedPhrase = phrase
        }
        expectation?.fulfill()
        expectation = nil
    }
    
    func speechRecognizerDidRecognize(_ phrase: String) {
        if expectation != nil {
            self.recognizedPhrase = phrase
        }
        expectation?.fulfill()
        expectation = nil
    }
    
    func speechRecognizerErrorDidOccur(error: Error) {
        if expectation != nil {
            self.error = error
        }
        expectation?.fulfill()
        expectation = nil
    }
}

final class SpeechRecognizerTests: XCTestCase {
    private var speechRecognizer: SpeechRecognizer!
    private var mockDelegate: MockSpeechRecognizerDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()
        speechRecognizer = SpeechRecognizer()
        mockDelegate = MockSpeechRecognizerDelegate(testCase: self)
        speechRecognizer.delegate = mockDelegate
    }

    override func tearDownWithError() throws {
        speechRecognizer = nil
        mockDelegate = nil
        try super.tearDownWithError()
    }

    func test_initialization_shouldNotBeNil() throws {
        XCTAssertNotNil(speechRecognizer)
        XCTAssertNotNil(speechRecognizer.delegate)
    }
}
