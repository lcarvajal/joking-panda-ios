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
    
    private var index: Int = 0
    private var isLastUserPhraseExpected: Bool = true
    
    internal var currentIndex: Int { return index }
    internal var lastPhraseUserSaid: String = ""
    internal var noMorePhrasesInDialogue: Bool {
        return getCurrentBotPhrase() == nil
    }
    
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
    
    // MARK: - Accessor methods
    
    internal func getCurrentUserPhrase() -> String? {
        return (index < userPhrases.count) ? userPhrases[index] : nil
    }
    
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
    
    private func isPhraseExpected(phraseSaid: String, expectedPhrase: String) -> Bool {
        return Tool.levenshtein(aStr: phraseSaid, bStr: expectedPhrase) < 7
    }
    
    // MARK: - Actions
    
    internal mutating func moveOnInDialogueIfNeeded() {
        guard let expectedUserPhrase = getCurrentUserPhrase() else {
            return
        }
        
        isLastUserPhraseExpected = isPhraseExpected(phraseSaid: lastPhraseUserSaid, expectedPhrase: expectedUserPhrase)
        if isLastUserPhraseExpected {
            index += 1
        }
        else {
            debugPrint("Not queing next phrase in dialogue since last phrase was not expected.")
        }
    }
}
