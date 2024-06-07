//
//  AudioPlayerTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/6/24.
//

import XCTest
import AVFAudio
@testable import JokingPanda

final class MockAudioPlayerDelegate: AudioPlayerDelegate {
    internal var didPlay = false
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
    
    func audioPlayerDidPlay() {
        if expectation != nil {
            didPlay = true
        }
        expectation?.fulfill()
        expectation = nil
    }
    
    func audioPlayerErrorDidOccur(error: any Error) {
        if expectation != nil {
            self.error = error
        }
        expectation?.fulfill()
        expectation = nil
    }
}

final class AudioPlayerTests: XCTestCase {
    var audioPlayer: AudioPlayer!
    var mockDelegate: MockAudioPlayerDelegate!
    var testURL: URL!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        audioPlayer = AudioPlayer()
        mockDelegate = MockAudioPlayerDelegate(testCase: self)
        audioPlayer.delegate = mockDelegate
        
        guard let url = Bundle.main.url(forResource: "knock-knock", withExtension: "m4a") else {
            throw NSError(domain: "Invalid URL", code: 1, userInfo: nil)
        }
        testURL = url
    }
    
    override func tearDownWithError() throws {
        audioPlayer = nil
        mockDelegate = nil
        testURL = nil
        try super.tearDownWithError()
    }
    
    func test_audioPlayer_withValidURL_shouldCallDidPlay() throws {
        mockDelegate.expectPlayAudio()
        audioPlayer.start(url: testURL)
        waitForExpectations(timeout: 1)
        
        let didPlay = try XCTUnwrap(mockDelegate.didPlay)
        XCTAssertTrue(didPlay)
        XCTAssertNil(mockDelegate.error)
    }
    
    func test_audioPlayer_withInvalidURL_shouldCallErrorDidOccur() throws {
        let invalidURL = URL(fileURLWithPath: "/invalid/path")
        mockDelegate.expectPlayAudio()
        audioPlayer.start(url: invalidURL)
        waitForExpectations(timeout: 1)
        
        let error = try XCTUnwrap(mockDelegate.error)
        XCTAssertNotNil(error)
        XCTAssertFalse(mockDelegate.didPlay)
        XCTAssertEqual(mockDelegate.error as? AudioPlayerError, AudioPlayerError.playerSetupFailed)
    }
}
