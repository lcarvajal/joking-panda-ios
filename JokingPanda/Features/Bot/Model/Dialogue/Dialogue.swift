//
//  Dialogue.swift
//  JokingPanda
//
/**
 Dialogue stores the phrases for a scripted back-and-forth conversation. For example, a knock-knock jokes or a riddle.
 */

import Foundation

struct Dialogue: Hashable, Codable, Identifiable {
    let id: Int
    let phrases: [String]
    let botPhrases: [String]
    let userPhrases: [String]
    
    private enum CodingKeys: String, CodingKey {
        case id, phrases
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        
        let phrases = try container.decode([String].self, forKey: .phrases)
        self.phrases = phrases
        self.botPhrases = stride(from: 0, to: phrases.count, by: 2).map { phrases[$0] }
        self.userPhrases = stride(from: 1, to: phrases.count, by: 2).map { phrases[$0] }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(phrases, forKey: .phrases)
    }
}
