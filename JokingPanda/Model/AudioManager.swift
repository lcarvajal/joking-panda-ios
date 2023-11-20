//
//  AudioManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/20/23.
//

import Foundation
import Speech

class AudioManager {
    internal let audioEngine = AVAudioEngine()
    
    private var audioPlayer: AVAudioPlayer? = nil
    private let audioSession = AVAudioSession.sharedInstance()
    
    // MARK: - Setup
    
    internal func activateAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .videoChat, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            // FIXME: Handle error
        }
    }
    
    internal func deactivateAudioSession() {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch {
            // FIXME: Handle error
        }
    }
    
    internal func deactivateAudioPlayer() {
        if let player = audioPlayer {
            player.delegate = nil
        }
        audioPlayer = nil
    }
    
    // MARK: - Actions
    
    internal func play(url: URL, delegate: AVAudioPlayerDelegate) {
        do {
            audioPlayer = nil
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            if let player = audioPlayer {
                player.delegate = delegate
                player.prepareToPlay()
                player.play()
            }
        } catch {
            // FIXME: Handle error
        }
    }
    
    internal func stopAudioEngine() {
        audioEngine.stop()
    }
}
