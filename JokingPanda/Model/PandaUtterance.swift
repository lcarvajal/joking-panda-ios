//
//  PandaUtterance.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/23/23.
//

import Foundation
import AVFoundation

class PandaUtterance: AVSpeechUtterance {
    override init(string: String) {
        super.init(string: string)
        
        // Configure the utterance.
        rate = 0.57
        pitchMultiplier = 0.8
        postUtteranceDelay = 0.2
        volume = 0.8
        
        // Retrieve the British English voice.
        let pandaVoice = AVSpeechSynthesisVoice(language: "en-GB")


        // Assign the voice to the utterance.
        voice = pandaVoice
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
