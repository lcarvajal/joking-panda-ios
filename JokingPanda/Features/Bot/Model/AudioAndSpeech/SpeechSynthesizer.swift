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

class SpeechSynthesizer: NSObject {
    weak var delegate: MouthDelegate?
    
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
        isSpeaking = true
        setUpAudioSession()
        synthesizer.botSpeak(string: phrase)
    }
    
    internal func stop() {
        isSpeaking = false
        deactivateAudioSession()
    }
    
    // MARK: - Set up
    
    private func setUpAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            // FIXME: Handle error
            debugPrint("Speech synthesis error setting audio session category: \(error.localizedDescription)")
        }
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

extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if isSpeaking {
            let phrase = (utterance.speechString as NSString).substring(with: characterRange)
            self.phraseSaid = phrase
            delegate?.isSayingPhrase(self.phraseSaid)
        }
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        synthesizer.stopSpeaking(at: .immediate)
        stop()
        let phrase = utterance.speechString
        self.phraseSaid = phrase
        delegate?.didSayPhrase(phrase)
    }
}
