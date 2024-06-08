//
//  Phrase.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation

struct Phrase: Hashable, Codable, Identifiable {
    var id: Int
    var lines: [String]
}
