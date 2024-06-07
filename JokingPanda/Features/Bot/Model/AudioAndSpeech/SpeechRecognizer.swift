//
//  SpeechRecognitionManager.swift
//  JokingPanda
//
/*
 Sets up an instance of SFSpeechRecognizer, passing `phraseHeard` through `isRecognizing()` and `didRecognize()` protocal methods.
 */

import Foundation
import Speech

protocol SpeechRecognizerDelegate: AnyObject {
    func speechRecognizerIsRecognizing(_ phrase: String)
    func speechRecognizerDidRecognize(_ phrase: String)
    func speechRecognizerErrorDidOccur(error: Error)
}

enum SpeechRecognizerError: LocalizedError {
    case audioEngineDidNotStart
    case initializeAudioBufferDidFail
    case noMicrophoneAccess
    
    var errorDescription: String? {
        switch self {
        case .audioEngineDidNotStart:
            return "Could Not Start Audio Engine"
        case .initializeAudioBufferDidFail:
            return "Could Not Create Audio Buffer"
        case .noMicrophoneAccess:
            return "Could Not Access Microphone"
        }
    }
}

class SpeechRecognizer: NSObject {
    internal weak var delegate: SpeechRecognizerDelegate?
    
    private let audioEngine: AVAudioEngine
    private var inputNode: AVAudioInputNode?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer
    
    @available(iOS 17, *)
    private var lmConfiguration: SFSpeechLanguageModel.Configuration {
        let outputDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dynamicLanguageModel = outputDir.appendingPathComponent("LM")
        let dynamicVocabulary = outputDir.appendingPathComponent("Vocab")
        return SFSpeechLanguageModel.Configuration(languageModel: dynamicLanguageModel, vocabulary: dynamicVocabulary)
    }
    
    private var expectedPhrase: String? = ""
    private var phraseHeard: String = ""
    private var isListening = false
    
    init(audioEngine: AVAudioEngine = AVAudioEngine(), speechRecognizer: SFSpeechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!) {
        self.audioEngine = audioEngine
        self.speechRecognizer = speechRecognizer
        
        super.init()
        speechRecognizer.delegate = self
        setUpLLM()
    }
    
    internal func start(expectedPhrase: String?) {
        if !isListening {
            phraseHeard = ""
            isListening = true
            self.expectedPhrase = expectedPhrase
            
            do {
                cancelRecognitionTask()
                inputNode = audioEngine.inputNode
                try setUpSpeechRecognizer()
                captureSpeech(repeatedInterval: .seconds(3))
            } catch {
                delegate?.speechRecognizerErrorDidOccur(error: error)
            }
        }
        else {
            debugPrint("Attempting to start speech recognizer while it's already running.")
        }
    }
    
    internal func stop() {
        isListening = false
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    // MARK: - Setup
    
    private func setUpLLM() {
        Task.detached {
            do {
                if let assetUrl = Bundle.main.url(forResource: "CustomLMDataForJokes.bin", withExtension: nil) {
                    try await SFSpeechLanguageModel.prepareCustomLanguageModel(for: assetUrl,
                                                                               clientIdentifier: Constant.AppProperty.bundleIdentifier,
                                                                               configuration: self.lmConfiguration)
                }
                else {
                    debugPrint("Error loading custom language model data file.")
                }
                
            } catch {
                NSLog("Failed to prepare custom LM: \(error.localizedDescription)")
            }
        }
    }
    
    private func setUpSpeechRecognizer() throws {
        try setUpRecognitionRequest()
        setUpRecognitionTask()
        try setUpMicrophoneInput()
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        }
        catch {
            throw SpeechRecognizerError.audioEngineDidNotStart
        }
    }
    
    private func setUpRecognitionRequest() throws {
        guard inputNode != nil else { return }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognizerError.initializeAudioBufferDidFail
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        if let expectedPhrase = self.expectedPhrase {
            recognitionRequest.contextualStrings = expectedPhrase.components(separatedBy: " ")
        }
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
            
            if #available(iOS 17, *) {
                recognitionRequest.customizedLanguageModel = self.lmConfiguration
            }
        }
    }
    
    private func setUpRecognitionTask() {
        setRecognitionTask { phraseHeard in
            if self.isListening {
                self.phraseHeard = phraseHeard
                self.delegate?.speechRecognizerIsRecognizing(phraseHeard)
            }
        } errorCompletion: { error in
            self.stop()
            if error != nil {
                debugPrint("Error capturing speech: \(error.debugDescription)")
            }
        }
    }
    
    private func setUpMicrophoneInput() throws {
        guard let inputNode = inputNode else {
            throw SpeechRecognizerError.noMicrophoneAccess
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
    }
    
    // MARK: - Actions
    
    private func captureSpeech(repeatedInterval: DispatchTimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + repeatedInterval) {
            if self.phraseHeard.isEmpty && self.isListening {
                // If user hasn't said anything, capture speech again
                self.captureSpeech(repeatedInterval: repeatedInterval)
            }
            else if self.isListening {
                self.delegate?.speechRecognizerDidRecognize(self.phraseHeard)
                self.stop()
            }
        }
    }
    
    private func cancelRecognitionTask() {
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
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                errorCompletion(error)
            }
        }
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    //    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    //        <#code#>
    //    }
}

