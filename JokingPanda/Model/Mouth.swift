//
//  Mouth.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 5/7/24.
//

import Foundation
import Speech

class Mouth: NSObject, ObservableObject {
    @Published var phraseSaid: String = ""
    
    private let audio: Audio
    private var speakCompletion: ((String) -> Void)?
    private let synthesizer = AVSpeechSynthesizer()
    
    init(audio: Audio) {
        self.audio = audio
    }
    
    internal func speak(phrase: String, completion: ((String) -> Void)?) {
        phraseSaid = ""
        speakCompletion = completion
        
        audio.activateAudioSession()
        playAudio(for: phrase)
    }
}

extension Mouth: AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    // MARK: - Speech Actions
    
    // MARK: - AVAudioPlayerDelegate
    
    private func playAudio(for phrase: String) {
        if let url = getAudioURL(for: phrase) {
            phraseSaid = phrase
            audio.play(url: url, delegate: self)
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
        audio.deactivateAudioPlayer()
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let phrase = (utterance.speechString as NSString).substring(with: characterRange)
        phraseSaid = phrase
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
