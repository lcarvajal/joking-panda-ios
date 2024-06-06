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
    
    func test_audioPlayer_withValidURL_shouldCallDidPlay() {
        audioPlayer.start(url: testURL)
        audioPlayer.stop()
        XCTAssertTrue(mockDelegate.didPlay)
        XCTAssertNil(mockDelegate.error)
    }
}
