//
//  Dialogue.swift
//  JokingPanda
//
/**
 Dialogue stores the phrases for a scripted back-and-forth conversation. For example, a knock-knock jokes or a riddle.
 */

import Foundation

struct Dialogue: Hashable, Codable, Identifiable {
    internal let id: Int
    internal let phrases: [String]
    private let botPhrases: [String]
    private let userPhrases: [String]
    
    private enum CodingKeys: String, CodingKey {
        case id, phrases
    }
    
    init(id: Int, phrases: [String]) {
        self.id = id
        self.phrases = phrases
        self.botPhrases = stride(from: 0, to: phrases.count, by: 2).map { phrases[$0] }
        self.userPhrases = stride(from: 1, to: phrases.count, by: 2).map { phrases[$0] }
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
    
    internal func getPhrase(for person: Person, index: Int) -> String? {
        switch person {
        case .bot:
            return (index < botPhrases.count) ? botPhrases[index] : nil
        case .currentUser:
            return (index < userPhrases.count) ? userPhrases[index] : nil
        }
    }
}
