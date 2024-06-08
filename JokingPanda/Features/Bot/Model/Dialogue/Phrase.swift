//
//  Phrase.swift
//  JokingPanda
//

import Foundation

struct Phrase: Hashable, Codable, Identifiable {
    var id: Int
    var lines: [String]
}
