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
    
    internal func start(url: URL) {
        setUpAudioSession()
        setUpAudioPlayer(url: url)
        startAudioPlayer()
    }
    
    internal func stop() {
        audioPlayer?.delegate = nil
        self.audioPlayer = nil
        deactivateAudioSession()
    }
    
    // MARK: - Set up
    
    private func setUpAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            // FIXME: Handle error
            debugPrint("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    private func setUpAudioPlayer(url: URL) {
        do {
            audioPlayer = nil
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
        } catch {
            // FIXME: Handle error
            debugPrint("Failed to set up audio player: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Actions
    
    private func startAudioPlayer() {
        guard let audioPlayer = self.audioPlayer else { return }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch {
            // FIXME: Handle error
        }
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // FIXME: Handle successful and unsuccessful cases
        stop()
        delegate?.didPlay()
    }
}
