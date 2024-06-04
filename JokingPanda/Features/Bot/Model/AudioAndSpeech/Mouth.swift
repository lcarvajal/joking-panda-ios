//
//  Mouth.swift
//  JokingPanda
//
/*
 Tries to play an audio file based on the phrase. For example, "Hello, world!" searches for `hello-world.m4a.
 If the file isn't found, a speech synthesizer tries saying the phrase out loud.
 As either method says the phrase outloud, `phraseSaid` is updated with what's being said.
 */

import Foundation
import Speech

protocol MouthDelegate: AnyObject {
    func isSayingPhrase(_ phrase: String)
    func didSayPhrase(_ phrase: String)
}

class Mouth: NSObject {
    weak var delegate: MouthDelegate?
    
    private var audioPlayer: AVAudioPlayer? = nil
    private var isSpeaking = false
    private var phraseSaid: String = ""
    private let synthesizer: AVSpeechSynthesizer
    
    init(synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()) {
        self.synthesizer = synthesizer
        super.init()
        synthesizer.delegate = self
    }
    
    internal func speak(phrase: String) {
        phraseSaid = ""
        playPhraseOutloud(phrase)
    }
    
    internal func stopSpeaking() {
        if let player = audioPlayer {
            player.delegate = nil
        }
        audioPlayer = nil
        isSpeaking = false
    }
}

extension Mouth: AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    // MARK: - AVAudioPlayerDelegate
    
    private func playPhraseOutloud(_ phrase: String) {
        isSpeaking = true
        
        if let url = Tool.getAudioURL(for: phrase) {
            phraseSaid = phrase
            delegate?.isSayingPhrase(self.phraseSaid)
            playAudio(url: url)
        }
        else {
            // Fallback on voice synthesis if audio file doesn't exist
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                self.synthesizer.botSpeak(string: phrase)
            }
            catch {
                // FIXME: Handle error
                debugPrint("Speech synthesis error setting audio session category: \(error.localizedDescription)")
            }
        }
    }
    
    private func playAudio(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            audioPlayer = nil
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            if let player = audioPlayer {
                player.delegate = self
                player.prepareToPlay()
                player.play()
            }
        } catch {
            // FIXME: Handle error
            debugPrint("Attempted to play file but got error: \(error.localizedDescription)")
        }
    }
    
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // FIXME: Handle successful and unsuccessful cases
        stopSpeaking()
        delegate?.didSayPhrase(self.phraseSaid)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if isSpeaking {
            let phrase = (utterance.speechString as NSString).substring(with: characterRange)
            self.phraseSaid = phrase
            delegate?.isSayingPhrase(self.phraseSaid)
        }
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        synthesizer.stopSpeaking(at: .immediate)
        stopSpeaking()
        let phrase = utterance.speechString
        self.phraseSaid = phrase
        delegate?.didSayPhrase(phrase)
    }
}
