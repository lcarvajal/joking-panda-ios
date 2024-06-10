//
//  Dialogue.swift
//  JokingPanda
//
/**
 Dialogue stores the phrases for a scripted back-and-forth conversation. For example, a knock-knock jokes or a riddle.
 `phrases` get organized into  `botPhrases` (odd indeces) and `userPhrases` (even indeces) on initialization.
 `index` keeps track of the position in the dialogue for `botPhrases` and `userPhrases`.
 */

import Foundation

struct Dialogue: Hashable, Codable, Identifiable {
    private enum CodingKeys: String, CodingKey {
        case id, phrases
    }
    
    private let botPhrases: [String]
    private let userPhrases: [String]
    private var index: Int = 0
    
    internal let id: Int
    internal let phrases: [String]
    
    internal var isLastUserPhraseExpected: Bool = true
    internal var lastPhraseUserSaid: String = "" {
        didSet {
            if let expectedUserPhrase = getCurrentUserPhrase() {
                // Less than x changes needed to match user input
                isLastUserPhraseExpected = Tool.levenshtein(aStr: lastPhraseUserSaid, bStr: expectedUserPhrase) < 7
            }
        }
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
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(phrases, forKey: .phrases)
    }
    
    // MARK: - Accessor methods
    
    /**
     - returns: String? user phrase at the current index
     */
    internal func getCurrentUserPhrase() -> String? {
        return (index < userPhrases.count) ? userPhrases[index] : nil
    }
    
    /**
     If a user says something unexpected, it will provide  a dynamic response instead of the phrase. If a user says something expected, it will return the bot phrase at the current index.
     - returns: String? bot phrase.
     */
    internal func getCurrentBotPhrase() -> String? {
        guard index < botPhrases.count else {
            return nil
        }
        
        let botPhrase = botPhrases[index]
        
        if isLastUserPhraseExpected {
            return botPhrase
        }
        else {
            guard let expectedUserPhrase = getCurrentUserPhrase() else {
                return botPhrase
            }
            
            switch expectedUserPhrase {
            case ConstantPhrase.whosThere:
                return ConstantPhrase.explainKnockKnock
            default:
                return ConstantPhrase.couldYouRepeatWhatYouSaid
            }
        }
    }
    
    // MARK: - Actions
    
    internal mutating func incrementIndexIfLastUserPhraseExpected() {
        if isLastUserPhraseExpected {
            index += 1
        }
        else {
            debugPrint("Not queing next phrase in dialogue since last phrase was not expected.")
        }
    }
}
