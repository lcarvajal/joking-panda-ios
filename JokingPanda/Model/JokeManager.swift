//
//  JokeManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//

import Foundation

struct JokeManager {
    internal var currentJoke: Conversation {
        return knockKnockJokes[index]
    }
    
    private var index = 0
    private let knockKnockJokes: [Conversation] = Tool.load("knockKnockJokeData.json")
    
    // MARK: - Setup
    
    init() {
        setIndexFromLastJokeHeard()
    }
    
    private mutating func setIndexFromLastJokeHeard() {
        // FIXME: Property should get set correctly for jokes
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.conversationId)
        if let index = knockKnockJokes.firstIndex(where: { $0.id == id }) {
            self.index = index
        }
    }
    
    // MARK: - Actions
    
    internal mutating func currentJokeWasHeard() {
        index += 1
        
        if index > (knockKnockJokes.count - 1) {
            index = 0
        }
        // FIXME: Property should get set correctly for jokes
        UserDefaults.standard.set(knockKnockJokes[index].id, forKey: Constant.UserDefault.conversationId)
    }
}
