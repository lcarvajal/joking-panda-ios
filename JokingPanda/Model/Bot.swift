//
//  Bot.swift
//  JokingPanda
//
/*
 The bot class takes care of the moving parts of the bot similar to how the body of a human takes care of the moving parts of a human. Nothing will happen without a brain but the body can wait, speak, and listen.
 This class:
 - Updates the animation state for waiting, speaking, and listening.
 - Updates the phrase and phrase history to display as the bot moves through different actions.
 - 'Speaks' by playing audio files and speech synthesizing with a voice synth if the audio file does not exist.
 - 'Listens' through a speech recognizer.
 */

import Foundation
import Speech

class Bot: NSObject, ObservableObject  {
    @Published var animationAction: AnimationStatus = .stopped
    @Published var phraseToDisplay: String = ""
    @Published var phraseHistory: String = ""
    
    private let audio: Audio
    private let ear: Ear
    private let mouth: Mouth
    
    override init() {
        audio = Audio()
        ear = Ear(audio: audio)
        mouth = Mouth(audio: audio)
        super.init()
    }
    
    internal func wait() {
        animationAction = .stopped
    }
}
