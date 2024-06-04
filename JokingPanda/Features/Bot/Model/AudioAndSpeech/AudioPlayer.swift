//
//  AudioPlayer.swift
//  JokingPanda
//

import Foundation
import AVFAudio

protocol AudioPlayerDelegate: AnyObject {
    func didPlay()
}

class AudioPlayer: NSObject {
    weak var delegate: AudioPlayerDelegate?
    
    private var audioPlayer: AVAudioPlayer? = nil
    
    internal func start(url: URL) throws {
        if audioPlayer == nil {
            try setUpAudioSession()
            try setUpAudioPlayer(url: url)
            startAudioPlayer()
        }
    }
    
    internal func stop() throws {
        audioPlayer?.delegate = nil
        audioPlayer = nil
        try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    // MARK: - Set up
    
    private func setUpAudioSession() throws {
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func setUpAudioPlayer(url: URL) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
    }
    
    // MARK: - Actions
    
    private func startAudioPlayer() {
        guard let audioPlayer = self.audioPlayer else { return }
        
        if !audioPlayer.isPlaying {
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // FIXME: Handle successful and unsuccessful cases
        try? stop()
        delegate?.didPlay()
    }
}
