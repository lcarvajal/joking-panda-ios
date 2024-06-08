//
//  main.swift
//  DataGenerator
//
//  Created by Lukas Carvajal on 6/7/24.
//

import Foundation
import Speech

// MARK: - Main

let userPhrases = loadUniqueUserLinesFromJokes()
let data = getCustomLanguageModelData(userPhrases: userPhrases)
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
    
    let jokeDialogues: [Dialogue] = Tool.load(Constant.FileName.knockKnockJokesJSON, url: url)
    
    let nestedUserPhrases = jokeDialogues.map { dialogue in
        stride(from: 1, to: dialogue.phrases.count, by: 2).map { dialogue.phrases[$0] }
    }
    let flattenedUserPhrases = nestedUserPhrases.reduce([], +)
    
    var uniqueUserPhrases: [String] = []
    for phrase in flattenedUserPhrases {
        if !uniqueUserPhrases.contains(phrase) {
            uniqueUserPhrases.append(phrase)
        }
    }
    
    return uniqueUserPhrases
}

/**
 Configures a custom language model so that lines a user is expected to say (f.e. 'I dunnapo') is recognized.
 */
internal func getCustomLanguageModelData(userPhrases: [String]) -> SFCustomLanguageModelData {
    let data = SFCustomLanguageModelData(locale: Locale(identifier: "en_US"), identifier: Constant.AppProperty.bundleIdentifier, version: "1.1") {
        //
        for phrase in userPhrases {
            SFCustomLanguageModelData.PhraseCount(phrase: phrase, count: 10)
        }
    }
    
    return data
}
