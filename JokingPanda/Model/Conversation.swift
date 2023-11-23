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

enum ConversationType {
    case deciding
    case dancing
    case joking
    case journaling
}
