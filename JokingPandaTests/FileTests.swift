//
//  JokingPandaTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 10/23/23.
//

import XCTest
@testable import JokingPanda

final class FileTests: XCTestCase {    
    func test_jokeAudioFiles_shouldExist() {
        if let acts: [Phrase] = Tool.load(Constant.FileName.knockKnockJokesJSON, url: nil) {
            for act in acts {
                for index in 0..<act.lines.count {
                    if index % 2 == 0 {
                        let fileName = Tool.removePunctuation(from: act.lines[index])
                            .lowercased()
                            .replacingOccurrences(of: " ", with: "-")
                            + ".m4a"
                        
                        let bundle = Bundle.main
                        if let path = bundle.path(forResource: fileName, ofType: nil) {
                            XCTAssertTrue(FileManager.default.fileExists(atPath: path), "File \(fileName) should exist")
                        } else {
                            XCTFail("File \(fileName) does not exist")
                        }
                    }
                }
            }
        }
        else {
            XCTFail("Error loading \(Constant.FileName.knockKnockJokesJSON)")
        }
    }
    
    func test_constantAudioFiles_shouldExist() {
        let constantLines = [
            ConstantLine.couldYouRepeatWhatYouSaid,
            ConstantLine.explainKnockKnock,
            ConstantLine.whosThere
        ]
        
        for line in constantLines {
            let fileName = Tool.removePunctuation(from: line)
                .lowercased()
                .replacingOccurrences(of: " ", with: "-")
                + ".m4a"
            
            let bundle = Bundle.main
            if let path = bundle.path(forResource: fileName, ofType: nil) {
                XCTAssertTrue(FileManager.default.fileExists(atPath: path), "File \(fileName) should exist")
            } else {
                XCTFail("File \(fileName) does not exist")
            }
        }
    }

    func test_customLLMFile_shouldExist() throws {
        let assetURL = Bundle.main.url(forResource: Constant.FileName.customLLM, withExtension: nil)
        XCTAssertNotNil(assetURL)
    }
}
