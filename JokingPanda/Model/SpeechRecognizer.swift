//
//  SpeechRecognitionManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/20/23.
//

import Foundation
import Speech

class SpeechRecognizer {
    private var inputNode: AVAudioInputNode?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    // MARK: - Setup
    
    internal func setDelegate(delegate: SFSpeechRecognizerDelegate) {
        speechRecognizer.delegate = delegate
    }
    
    internal func setInputNode(inputNode: AVAudioInputNode) {
        self.inputNode = inputNode
    }
    
    private func configureMicrophoneInput() {
        guard let inputNode = inputNode else { return }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
    }
    
    private func configureRecognitionRequest(expectedPhrase: String) {
        guard let inputNode = inputNode else { return }
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.contextualStrings = expectedPhrase.components(separatedBy: " ")
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
            if #available(iOS 17, *) {
                //                recognitionRequest.customizedLanguageModel = self.lmConfiguration
            }
        }
        
    }
    
    // MARK: - Actions
    
    internal func configure(expectedPhrase: String, completion: @escaping ((String) -> Void), errorCompletion: @escaping ((any Error)?) -> Void) {
        cancelCurrentRecognitionTask()
        configureRecognitionRequest(expectedPhrase: expectedPhrase)
        setRecognitionTask(completion: completion, errorCompletion: errorCompletion)
        configureMicrophoneInput()
    }
    
    internal func stop() {
        recognitionRequest?.endAudio()
    }
    
    private func cancelCurrentRecognitionTask() {
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }
    
    private func setRecognitionTask(completion: @escaping ((String) -> Void), errorCompletion: @escaping ((any Error)?) -> Void) {
        guard let inputNode = inputNode else { return }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { [self] result, error in
            var isFinal = false
            
            if let result = result {
                isFinal = result.isFinal
                completion(result.bestTranscription.formattedString)
            }
            
            if error != nil || isFinal {
                // FIXME: Handle error
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                errorCompletion(error)
            }
        }
    }
}
