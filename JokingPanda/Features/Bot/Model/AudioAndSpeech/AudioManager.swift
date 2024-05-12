//
//  Audio.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/20/23.
//

import Foundation
import Speech

class AudioManager {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer? = nil
    private let audioSession = AVAudioSession.sharedInstance()
    
    // MARK: - Setup
    
    internal func activateAudioPlaybackSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            // FIXME: Handle error
            debugPrint("Audio Playback error setting audio session category: \(error.localizedDescription)")
        }
    }
    
    internal func activateAudioSpeechSynthesizerSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            // FIXME: Handle error
            debugPrint("Speech synthesis error setting audio session category: \(error.localizedDescription)")
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
            debugPrint("Attempted to play file but got error: \(error.localizedDescription)")
        }
    }
}
