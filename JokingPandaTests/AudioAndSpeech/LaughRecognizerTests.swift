//
//  LaughRecognizerTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/7/24.
//

import XCTest
@testable import JokingPanda

final class MockLaughRecognizerDelegate: LaughRecognizerDelegate {
    internal var loudness: Float = 0
    internal var error: Error? = nil
    
    private var expectation: XCTestExpectation?
    private let testCase: XCTestCase
    
    init(testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    internal func expectPlayAudio() {
        expectation = testCase.expectation(description: "Expect audio to play")
    }
    
    // MARK: - AudioPlayer delegate methods
    
    func laughRecognizerIsRecognizing(loudness: Float) {
        if expectation != nil {
            self.loudness = loudness
        }
        expectation?.fulfill()
        expectation = nil
    }
    
    func laughRecognizerDidRecognize(loudness: Float) {
        if expectation != nil {
            self.loudness = loudness
        }
        expectation?.fulfill()
        expectation = nil
    }
    
    func laughRecognizerErrorDidOccur(error: any Error) {
        if expectation != nil {
            self.error = error
        }
        expectation?.fulfill()
        expectation = nil
    }
}

final class LaughRecognizerTests: XCTestCase {
    private var laughRecognizer: LaughRecognizer!
    private var mockDelegate: MockLaughRecognizerDelegate!

    override func setUpWithError() throws {
        laughRecognizer = LaughRecognizer()
        mockDelegate = MockLaughRecognizerDelegate(testCase: self)
        laughRecognizer.delegate = mockDelegate
    }

    override func tearDownWithError() throws {
        laughRecognizer = nil
        mockDelegate = nil
    }

}
