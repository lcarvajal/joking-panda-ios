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
        self.action = action
    }
    
    func currentPhraseDidUpdate(phrase: String) {
        self.currentPhrase = phrase
    }
    
    func phraseHistoryDidUpdate(phraseHistory: String) {
        self.phraseHistory = phraseHistory
    }
}
