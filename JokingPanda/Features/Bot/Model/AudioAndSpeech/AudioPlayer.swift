//
//  AudioPlayer.swift
//  JokingPanda
//

import Foundation
import AVFAudio

protocol AudioPlayerDelegate: AnyObject {
    func didPlay()
    func errorDidOccur(error: Error)
}

enum AudioPlayerError: LocalizedError {
    case audioPlaybackFailed
    case playerSetupFailed
    case sessionSetupFailed
    
    var errorDescription: String? {
        switch self {
        case .audioPlaybackFailed:
            return "Could not play audio."
        case .playerSetupFailed:
            return "Audio player setup failed."
        case .sessionSetupFailed:
            return "Audio session setup failed."
        }
    }
}

class AudioPlayer: NSObject {
    weak var delegate: AudioPlayerDelegate?
    
    private var audioPlayer: AVAudioPlayer? = nil
    
    internal func start(url: URL) {
        if audioPlayer == nil {
            do {
                try setUpAudioSession()
                try setUpAudioPlayer(url: url)
                try startAudioPlayer()
            }
            catch {
                delegate?.errorDidOccur(error: error)
            }
        }
        else {
            debugPrint("Attempting to start audio player after it's already been started.")
        }
    }
    
    internal func stop() {
        audioPlayer?.delegate = nil
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    // MARK: - Set up
    
    private func setUpAudioSession() throws {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            throw AudioPlayerError.sessionSetupFailed
        }
    }
    
    private func setUpAudioPlayer(url: URL) throws {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
        }
        catch {
            throw AudioPlayerError.playerSetupFailed
        }
    }
    
    // MARK: - Actions
    
    private func startAudioPlayer() throws {
        guard let audioPlayer = self.audioPlayer else {
            throw AudioPlayerError.playerSetupFailed
        }
        
        if !audioPlayer.isPlaying {
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
        
        if flag {
            delegate?.didPlay()
        } else {
            delegate?.errorDidOccur(error: AudioPlayerError.audioPlaybackFailed)
        }
        
    }
}
