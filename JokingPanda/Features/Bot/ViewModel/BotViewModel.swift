//
//  BotViewModel.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 5/8/24.
//

import SwiftUI

@Observable class BotViewModel {
    internal var action: AnimationAction = .stopped
    internal var error: Error?
    internal var currentPhrase: String = ""
    internal var laughLoudness: Float = 0
    internal var phraseHistory: String = "Tap the panda to get started!"
    
    private var bot: Bot
    
    init(bot: Bot = Bot()) {
        self.bot = bot
        self.bot.delegate = self
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
            self.laughLoudness = loudness
        }
    }
    
    func phraseHistoryDidUpdate(phraseHistory: String) {
        DispatchQueue.main.async {
            self.phraseHistory = phraseHistory
        }
    }
}
