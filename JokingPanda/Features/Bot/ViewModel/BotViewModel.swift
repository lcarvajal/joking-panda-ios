//
//  BotViewModel.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 5/8/24.
//

import SwiftUI

@Observable class BotViewModel {
    internal var action: AnimationAction = .stopped
    internal var currentPhrase: String = ""
    internal var laughLoudness: Float = 0
    internal var phraseHistory: String = "Tap the panda to get started!"
    
    private var bot: Bot = Bot()
    
    init() {
        bot.delegate = self
    }
    
    internal func startConversation() {
        phraseHistory = ""
        bot.startConversation()
    }
    
    internal func stopEverything() {
        bot.stopEverything()
    }
}

extension BotViewModel: BotDelegate {
    func actionDidUpdate(action: AnimationAction) {
        DispatchQueue.main.async {
            self.action = action
        }
    }
    
    func currentPhraseDidUpdate(phrase: String) {
        DispatchQueue.main.async {
            self.currentPhrase = phrase
        }
    }
    
    func laughLoudnessDidUpdate(loudness: Float) {
        DispatchQueue.main.async {
            print("Shouldn't this update?")
            self.currentPhrase = "Laugh meter: \(loudness)"
        }
    }
    
    func phraseHistoryDidUpdate(phraseHistory: String) {
        DispatchQueue.main.async {
            self.phraseHistory = phraseHistory
        }
    }
}
