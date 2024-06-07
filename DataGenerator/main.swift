//
//  main.swift
//  DataGenerator
//
//  Created by Lukas Carvajal on 6/7/24.
//

import Foundation
import Speech

// MARK: - Main

let userLines = loadUniqueUserLinesFromJokes()
let data = getCustomLanguageModelData(userLines: userLines)
try await data.export(to: URL(filePath: Constant.FilePath.tempCustomLLMData))

// MARK: - Helper functions

/**
 Loads unique user lines from file located in resources directory of iOS app.
 */
private func loadUniqueUserLinesFromJokes() -> [String] {
    let fileManager = FileManager.default
    let currentPath = fileManager.currentDirectoryPath
    let resourcePath = currentPath + "/" + Constant.FileName.knockKnockJokesJSON
    let url = URL(fileURLWithPath: resourcePath)
    
    let jokingActs: [Act] = Tool.load(Constant.FileName.knockKnockJokesJSON, url: url)
    
    let nestedUserLines = jokingActs.map { act in
        stride(from: 1, to: act.lines.count, by: 2).map { act.lines[$0] }
    }
    let flattenedUserLines = nestedUserLines.reduce([], +)
    
    var uniqueUserLines: [String] = []
    for line in flattenedUserLines {
        if !uniqueUserLines.contains(line) {
            uniqueUserLines.append(line)
        }
    }
    
    return uniqueUserLines
}

/**
 Configures a custom language model so that lines a user is expected to say (f.e. 'I dunnapo') is recognized.
 */
internal func getCustomLanguageModelData(userLines: [String]) -> SFCustomLanguageModelData {
    let data = SFCustomLanguageModelData(locale: Locale(identifier: "en_US"), identifier: "com.JokingPanda", version: "1.1") {
        //
        for line in userLines {
            SFCustomLanguageModelData.PhraseCount(phrase: line, count: 10)
        }
    }
    
    return data
}
