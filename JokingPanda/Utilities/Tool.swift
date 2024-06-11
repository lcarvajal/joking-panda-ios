//
//  Tool.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/30/23.
//

import Foundation

struct Tool {
    static func countMatchingWords(input: String, expected: String) -> Int {
        // Remove punctuation and convert to lowercase
        let cleanedInput = Tool.removePunctuation(from: input).lowercased()
        let cleanedExpected = Tool.removePunctuation(from: expected).lowercased()
        
        // Split into sets of words
        let inputWords = Set(cleanedInput.split(separator: " "))
        let expectedWords = Set(cleanedExpected.split(separator: " "))
        
        // Find the intersection of the sets
        let matchingWords = inputWords.intersection(expectedWords)
        return matchingWords.count
    }
    
    // Get the number of character changes to get from string a to string b
    static func levenshtein(aStr: String, bStr: String) -> Int {
        if aStr.count < 1 || bStr.count < 1 {
            return abs(aStr.count - bStr.count)
        }
        
        let a = Array(aStr.utf16)
        let b = Array(bStr.utf16)
        
        let dist = Array2D(cols: a.count + 1, rows: b.count + 1)
        
        for i in 1...a.count {
            dist[i, 0] = i
        }
        
        for j in 1...b.count {
            dist[0, j] = j
        }
        
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i, j] = dist[i-1, j-1]  // noop
                } else {
                    dist[i, j] = min(
                        numbers: dist[i-1, j] + 1,  // deletion
                        dist[i, j-1] + 1,  // insertion
                        dist[i-1, j-1] + 1  // substitution
                    )
                }
            }
        }
        
        return dist[a.count, b.count]
    }
    
    // Load data from a file
    static func load<T: Decodable>(_ filename: String, url: URL?) -> T {
        let data: Data
        let validURL: URL
        
        if let url = url {
            validURL = url
        }
        else if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
            validURL = url
        }
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: validURL)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
    static func min(numbers: Int...) -> Int {
        return numbers.reduce(numbers[0]) {$0 < $1 ? $0 : $1}
    }
    
    static func removePunctuation(from text: String) -> String {
        // Define a regular expression pattern to match punctuation characters
        let punctuationPattern = #"[.,\/#?'!$%\^&\*;:{}=\-_`’~()]"#

        // Use the regular expression to find and replace punctuation with an empty string
        let cleanedText = text.replacingOccurrences(of: punctuationPattern, with: "", options: .regularExpression, range: nil)

        return cleanedText
    }
    
    static func getAudioURL(for phrase: String) -> URL? {
        let audioFileName = Tool.removePunctuation(from: phrase)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        return Bundle.main.url(forResource: audioFileName, withExtension: "m4a")
    }
    
    static func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }
}

class Array2D {
    var cols:Int, rows:Int
    var matrix: [Int]
    
    
    init(cols:Int, rows:Int) {
        self.cols = cols
        self.rows = rows
        matrix = Array(repeating:0, count:cols*rows)
    }
    
    subscript(col:Int, row:Int) -> Int {
        get {
            return matrix[cols * row + col]
        }
        set {
            matrix[cols*row+col] = newValue
        }
    }
    
    func colCount() -> Int {
        return self.cols
    }
    
    func rowCount() -> Int {
        return self.rows
    }
}
