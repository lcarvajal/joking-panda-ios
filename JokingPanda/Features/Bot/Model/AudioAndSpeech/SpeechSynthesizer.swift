//
//  Mouth.swift
//  JokingPanda
//
/*
 Sets up an instance of AVSpeechSynthesizer.
 */

import Foundation
import Speech

protocol SpeechSynthesizerDelegate: AnyObject {
    func speechSynthesizerIsSayingPhrase(_ phrase: String)
    func speechSynthesizerDidSayPhrase(_ phrase: String)
    func speechSynthesizerErrorDidOccur(error: Error)
}

enum SpeechSynthesizerError: LocalizedError {
    case sessionSetupDidFail
    
    var errorDescription: String? {
        switch self {
        case .sessionSetupDidFail:
            return "Could Not Set Up Audio Session"
        }
    }
}

class SpeechSynthesizer: NSObject {
    weak var delegate: SpeechSynthesizerDelegate?
    
    private var isSpeaking = false
    private var phraseSaid: String = ""
    private let synthesizer: AVSpeechSynthesizer
    
    init(synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()) {
        self.synthesizer = synthesizer
        super.init()
        synthesizer.delegate = self
    }
    
    internal func speak(phrase: String) {
        if !isSpeaking {
            phraseSaid = ""
            isSpeaking = true
            
            do {
                try setUpAudioSession()
                synthesizer.botSpeak(string: phrase)
            }
            catch {
                delegate?.speechSynthesizerErrorDidOccur(error: error)
            }
        }
    }
    
    internal func stop() {
        isSpeaking = false
        try? deactivateAudioSession()
    }
    
    // MARK: - Set up
    
    private func setUpAudioSession() throws {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            throw SpeechSynthesizerError.sessionSetupDidFail
        }
    }
    
    private func deactivateAudioSession() throws {
        try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if isSpeaking {
            let phrase = (utterance.speechString as NSString).substring(with: characterRange)
            self.phraseSaid = phrase
            delegate?.speechSynthesizerIsSayingPhrase(self.phraseSaid)
        }
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        synthesizer.stopSpeaking(at: .immediate)
        stop()
        let phrase = utterance.speechString
        self.phraseSaid = phrase
        delegate?.speechSynthesizerDidSayPhrase(phrase)
    }
}
