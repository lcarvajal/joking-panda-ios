//
//  JokingPandaTests.swift
//  JokingPandaTests
//
//  Created by Lukas Carvajal on 10/23/23.
//

import XCTest
@testable import JokingPanda

final class JokingPandaTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testKnockKnockAudioFilesExist() {
        if let acts: [Act] = Tool.load(Constant.FileName.knockKnockJokesJSON) {
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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
