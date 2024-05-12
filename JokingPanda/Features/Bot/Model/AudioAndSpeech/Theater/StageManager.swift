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
    internal var lastAct: Act { return currentPlay.lastAct }
    
    private var selectedType: ActType = .joking
    private var currentPlay: Play { return plays[selectedType]! }
    private var personActing: Person { return currentPlay.personActing }
    private let plays: [ActType: Play]
    
    // MARK: - Setup
    
    init(plays: [ActType: Play]) {
        self.plays = plays
    }
    
    // MARK: - Actions
    
    internal func startAct(type: ActType? = nil) {
        if let type = type {
            selectedType = type
        }
        
        currentPlay.startAct()
    }
    
    internal func stopAct() {
        currentPlay.stopAct()
    }
    
    internal func queueNextLine() {
        currentPlay.queueNextLine()
    }
}
