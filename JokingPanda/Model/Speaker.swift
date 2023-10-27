//
//  Speaker.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/23/23.
//

import Foundation
import Speech

class Speaker: NSObject, ObservableObject {
    @Published var isShowingSpeakingErrorAlert = false
    
    internal var errorDescription: String?
    internal let synthesizer = AVSpeechSynthesizer()
    
    internal func speak(_ text: String) {
        do {
            let utterance = AVSpeechUtterance(string: text)
            utterance.rate = 0.57
            utterance.pitchMultiplier = 0.8
            utterance.postUtteranceDelay = 0.2
            utterance.volume = 0.8
            
            // Assign the voice to the utterance.
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            self.synthesizer.speak(utterance)
        } catch let error {
            self.errorDescription = error.localizedDescription
            isShowingSpeakingErrorAlert.toggle()
        }
    }
    
    internal func stop() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
}
