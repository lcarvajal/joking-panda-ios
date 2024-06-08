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
    internal var lastAct: Dialogue { return currentPlay.lastAct }
    
    private var currentPlay: DialogueManager { return plays[0] }
    private var personActing: Person { return currentPlay.personActing }
    private let plays: [DialogueManager]
    
    static func loadedWithJokes() -> StageManager {
        let jokingActs: [Dialogue] = Tool.load(Constant.FileName.knockKnockJokesJSON, url: nil)
        
        let plays = [
            DialogueManager(acts: jokingActs)
        ]
        
        return StageManager(plays: plays)
    }
    
    // MARK: - Setup
    
    init(plays: [DialogueManager]) {
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
