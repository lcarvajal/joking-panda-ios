//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation

struct ConversationManager {
    internal var conversations: [Conversation] = [Conversation(
        botPhrases: ["Knock, knock!", "Joking.", "Joking panda!"],
        expectedUserPhrases: ["Who's there?", "Joking who?"]
    )]
    internal var personToStartTalking = Person.bot
    internal var conversationIndex = -1
}
