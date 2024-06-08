//
//  Dialogue.swift
//  JokingPanda
//

import Foundation

struct Dialogue: Hashable, Codable, Identifiable {
    var id: Int
    var lines: [String]
}
