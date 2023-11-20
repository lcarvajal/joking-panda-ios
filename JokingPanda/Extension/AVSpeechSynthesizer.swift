//
//  AVSpeechSynthesizer.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/20/23.
//

import Foundation
import Speech

extension AVSpeechSynthesizer {
    internal func botSpeak(string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.rate = 0.45
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        
        speak(utterance)
    }
}
