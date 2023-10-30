//
//  Conversation.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation

struct Conversation: Hashable, Codable, Identifiable {
    var id: Int
    var phrases: [String]
}

enum ConversationStatus {
    case botSpeaking
    case currentUserSpeaking
    case noOneSpeaking
    case stopped
}
