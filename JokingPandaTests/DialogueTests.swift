//
//  DialogueTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 6/8/24.
//

import XCTest
@testable import JokingPanda

final class DialogueTests: XCTestCase {
    private var dialogueManager: DialogueManager!

    override func setUpWithError() throws {
        let mockDialogues = [
            Dialogue(id: 1, phrases: ["Knock, knock.","Who's there?","Tank.","Tank who?","You’re welcome."]),
            Dialogue(id: 2, phrases: ["Kick, kick.","Who's there?","A panda with his arms full of bamboo!"]),
            Dialogue(id: 3, phrases: ["Knock, knock.","Who's there?","Heidi.","Heidi who?","Heidi 'cided to come over to play!"])
        ]
        
        dialogueManager = DialogueManager(dialogues: mockDialogues)
    }

    override func tearDownWithError() throws {
        dialogueManager = nil
    }
    
    
}
