//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//

import Foundation

class StageManager: NSObject, ObservableObject {
    @Published var history = ""
    @Published var selectedType: ActType = .deciding
    
    internal var currentPlay: Play { return plays[selectedType]! }
    internal var currentLine: String { return currentPlay.currentLine }
    internal var isStartOfAct: Bool { return currentPlay.isStartOfAct }
    internal var isActing: Bool { return currentPlay.isActing }
    internal var personActing: Person { return currentPlay.personActing }
    
    private let plays: [ActType: Play] = [
        .deciding : Play(type: .deciding),
        .joking: Play(type: .joking)
    ]
    private var phraseHistory: [String] = []
    
    // MARK: - Setup
    
    // MARK: - Actions
    
    internal func startConversation(type: ActType? = nil) {
        if let type = type {
            selectedType = type
        }
        
        if history != "" {
            history += "\n"
        }
        
        currentPlay.startConversation()
    }
    
    internal func stopConversation() {
        currentPlay.stopConversation()
    }
    
    internal func queueNextPhrase() {
        if currentPlay.personActing == .currentUser,
           let lastPhrase = phraseHistory.last,
           let trigger = getConversationShiftTrigger(phrase: lastPhrase),
           trigger != selectedType {
            currentPlay.queueNextPhrase()
            currentPlay.stopConversation()
            startConversation(type: trigger)
        }
        else {
            currentPlay.queueNextPhrase()
        }
    }
    
    private func getConversationShiftTrigger(phrase: String) -> ActType? {
        let phraseToCheck = phrase.lowercased()
        
        switch selectedType {
        case .deciding:
            if phraseToCheck.contains("joke") {
                return .joking
            }
            else {
                return nil
            }
        default:
            return nil
        }
    }
    
    internal func updateConversationHistory(_ recognizedSpeech: String? = nil) {
        if history != "" {
            history += "\n"
        }
        
        var phraseToAdd = currentLine
        if let speech = recognizedSpeech {
            if selectedType == .joking {
                // Use recognized speech if it is very different from the current expected phrase
                phraseToAdd = Tool.levenshtein(aStr: speech, bStr: currentLine) < 5 ? currentLine : speech
            }
            else {
                phraseToAdd = speech
            }
        }
        phraseHistory.append(phraseToAdd)
        
        switch personActing {
        case .bot:
            phraseToAdd = "🐼 " + phraseToAdd
        case .currentUser:
            phraseToAdd = "🗣️ " + phraseToAdd
        }
        
        history += phraseToAdd
    }
}
