//
//  Speaker.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/23/23.
//

import Foundation
import Speech

class Speaker: NSObject, ObservableObject {
    internal let synthesizer = AVSpeechSynthesizer()
    
    internal func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        
        // Assign the voice to the utterance.
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        self.synthesizer.speak(utterance)
    }
    
    internal func stop() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
}
