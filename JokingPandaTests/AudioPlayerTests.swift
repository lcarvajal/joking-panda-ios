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
    var didPlay = false
    var didError: Error? = nil
    
    func audioPlayerDidPlay() {
        didPlay = true
    }
    
    func audioPlayerErrorDidOccur(error: any Error) {
        didError = error
    }
}

final class AudioPlayerTests: XCTestCase {
    var audioPlayer: AudioPlayer!
    var mockDelegate: MockAudioPlayerDelegate!
    var testURL: URL!
    
    override func setUp() {
        super.setUp()
        audioPlayer = AudioPlayer()
        mockDelegate = MockAudioPlayerDelegate()
        audioPlayer.delegate = mockDelegate
        testURL = Bundle.main.url(forResource: "knock-knock", withExtension: "m4a")
    }

    override func tearDown() {
        audioPlayer = nil
        mockDelegate = nil
        testURL = nil
        super.tearDown()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
}
