//
//  LaughRecognizerTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/7/24.
//

import XCTest
@testable import JokingPanda

final class MockLaughRecognizerDelegate: LaughRecognizerDelegate {
    internal var loudness: Float? = nil
    internal var error: Error? = nil
    
    private var expectation: XCTestExpectation?
    private let testCase: XCTestCase
    
    init(testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    internal func expectRecognizeLaughter() {
        expectation = testCase.expectation(description: "Expect recognized laughter")
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

    func test_initialization_shouldNotBeNil() throws {
        XCTAssertNotNil(laughRecognizer)
        XCTAssertNotNil(laughRecognizer.delegate)
    }
    
    func test_start_withRecognizingInProgress_shouldNotThrowError() throws {
        mockDelegate.expectRecognizeLaughter()
        laughRecognizer.start(for: .seconds(2))
        laughRecognizer.start(for: .seconds(2))
        
        waitForExpectations(timeout: 2)
        
        let loudness = try XCTUnwrap(mockDelegate.loudness)
        XCTAssertNotNil(loudness)
        XCTAssertNil(mockDelegate.error)
    }
}
