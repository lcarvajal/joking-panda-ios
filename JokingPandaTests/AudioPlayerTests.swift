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
    var error: Error? = nil
    
    func audioPlayerDidPlay() {
        didPlay = true
    }
    
    func audioPlayerErrorDidOccur(error: any Error) {
        self.error = error
    }
}

final class AudioPlayerTests: XCTestCase {
    var audioPlayer: AudioPlayer!
    var mockDelegate: MockAudioPlayerDelegate!
    var testURL: URL!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        audioPlayer = AudioPlayer()
        mockDelegate = MockAudioPlayerDelegate()
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
    
    func test_audioPlayer_withValidURL_shouldCallDidPlay() {
        audioPlayer.start(url: testURL)
        XCTAssertTrue(mockDelegate.didPlay)
        XCTAssertNil(mockDelegate.error)
    }
    
    func test_audioPlayer_withInvalidURL_shouldCallErrorDidOccur() {
        let invalidURL = URL(fileURLWithPath: "/invalid/path")
        audioPlayer.start(url: invalidURL)
        XCTAssertFalse(mockDelegate.didPlay)
        XCTAssertNotNil(mockDelegate.error)
        XCTAssertEqual(mockDelegate.error as? AudioPlayerError, AudioPlayerError.playerSetupFailed)
    }
}
