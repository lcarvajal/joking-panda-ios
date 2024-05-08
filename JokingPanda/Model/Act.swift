//
//  Script.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation

struct Act: Hashable, Codable, Identifiable {
    var id: Int
    var phrases: [String]
}

enum ActType {
    case deciding
    case joking
}
