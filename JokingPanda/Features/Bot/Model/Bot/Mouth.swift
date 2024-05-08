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
    
    private var phraseSaid: String = ""
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    internal func speak(phrase: String) {
        phraseSaid = ""
        AudioManager.shared.activateAudioSession()
        playAudio(for: phrase)
    }
    
    internal func stopSpeaking() {
        AudioManager.shared.deactivateAudioPlayer()
    }
}

extension Mouth: AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    // MARK: - AVAudioPlayerDelegate
    
    private func playAudio(for phrase: String) {
        if let url = getAudioURL(for: phrase) {
            phraseSaid = phrase
            AudioManager.shared.play(url: url, delegate: self)
        }
        else {
            // Fallback on voice synthesis if audio file doesn't exist
            self.synthesizer.botSpeak(string: phrase)
        }
    }
    
    private func getAudioURL(for phrase: String) -> URL? {
        let audioFileName = Tool.removePunctuation(from: phrase)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        return Bundle.main.url(forResource: audioFileName, withExtension: "m4a")
    }
    
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // FIXME: Handle successful and unsuccessful cases
        stopSpeaking()
        delegate?.didSayPhrase(self.phraseSaid)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let phrase = (utterance.speechString as NSString).substring(with: characterRange)
        self.phraseSaid = phrase
        delegate?.isSayingPhrase(self.phraseSaid)
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        synthesizer.stopSpeaking(at: .immediate)
        delegate?.didSayPhrase(self.phraseSaid)
    }
}
