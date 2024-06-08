//
//  Dialogue.swift
//  JokingPanda
//
/**
 Dialogue stores the phrases for a scripted back-and-forth conversation. For example, a knock-knock jokes or a riddle.
 */

import Foundation

struct Dialogue: Hashable, Codable, Identifiable {
    var id: Int
    var phrases: [String]
}
