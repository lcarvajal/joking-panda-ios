//
//  SpeechRecognitionManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/20/23.
//

import Foundation
import Speech

class SpeechRecognitionManager {
    internal var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    internal var recognitionTask: SFSpeechRecognitionTask?
    internal let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    internal func configureRecognitionRequest(phrase: String, inputNode: AVAudioInputNode) {
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.contextualStrings = phrase.components(separatedBy: " ")
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
            if #available(iOS 17, *) {
                //                recognitionRequest.customizedLanguageModel = self.lmConfiguration
            }
        }
        
    }
    
    internal func cancelCurrentRecognitionTask() {
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }
}
