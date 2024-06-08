//
//  Dialogue.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/22/23.
//

import Foundation

class PhraseManager {
    internal var currentAct: Phrase { return acts[actIndex] }
    internal var lastAct: Phrase { return acts[actIndex - 1]}
    internal var currentLine: String { return currentAct.lines[lineIndex] }
    internal var previousLine: String? {
        if lineIndex > 0 {
            return currentAct.lines[lineIndex - 1]
        }
        else {
            return nil
        }
    }
    
    internal var isStartOfAct: Bool { return lineIndex == 0 }
    internal var isActing = false
    internal var personActing: Person { return lineIndex % 2 == 0 ? Person.bot : Person.currentUser }
    
    private let acts: [Phrase]
    private var actIndex = 0
    private var lineIndex = 0
    
    init(acts: [Phrase]) {
        self.acts = acts
        pickUpLastAct()
    }
    
    private func pickUpLastAct() {
        // FIXME: Property should get set correctly for conversation type
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.actId)
        if let index = acts.firstIndex(where: { $0.id == id }) {
            self.actIndex = index
        }
    }
    
    // MARK: - Actions
    
    internal func startAct() {
        isActing = true
        
        // FIXME: Property should get set correctly for different conversation types
        Event.track(Constant.Event.conversationStarted, properties: [
            Constant.Event.Property.actId: currentAct.id
          ])
    }
    
    internal func stopAct() {
        lineIndex = 0
        isActing = false
        queueNextAct()
    }
    
    internal func queueNextLine() {
        lineIndex += 1
        
        if lineIndex > (currentAct.lines.count - 1) {
            stopAct()
        }
    }
    
    private func queueNextAct() {
        actIndex += 1
        
        if actIndex > (acts.count - 1) {
            actIndex = 0
        }
        
        // FIXME: Property should get set correctly for conversation types
        UserDefaults.standard.set(acts[actIndex].id, forKey: Constant.UserDefault.actId)
    }
}
