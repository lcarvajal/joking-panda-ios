//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//

import Foundation

class StageManager {
    internal var isStartOfAct: Bool { return currentPlay.isStartOfAct }
    internal var isRunningAnAct: Bool { return currentPlay.isActing }
    internal var currentLine: String { return currentPlay.currentLine }
    internal var previousLine: String? { return currentPlay.previousLine }
    internal var lastAct: Phrase { return currentPlay.lastAct }
    
    private var currentPlay: PhraseManager { return plays[0] }
    private var personActing: Person { return currentPlay.personActing }
    private let plays: [PhraseManager]
    
    static func loadedWithJokes() -> StageManager {
        let jokingActs: [Phrase] = Tool.load(Constant.FileName.knockKnockJokesJSON, url: nil)
        
        let plays = [
            PhraseManager(acts: jokingActs)
        ]
        
        return StageManager(plays: plays)
    }
    
    // MARK: - Setup
    
    init(plays: [PhraseManager]) {
        self.plays = plays
    }
    
    // MARK: - Actions
    
    internal func startAct() {
        currentPlay.startAct()
    }
    
    internal func stopAct() {
        currentPlay.stopAct()
    }
    
    internal func queueNextLine() {
        currentPlay.queueNextLine()
    }
}
