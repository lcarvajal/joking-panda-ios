//
//  SpeechRecognizer.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/23/23.
//

import Foundation
import Speech

class SpeechRecognizer: NSObject, ObservableObject {
    @Published var isRecording = false
    
    internal let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))!
    internal var speechRecognized = ""
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @available(iOS 17, *)
    private var lmConfiguration: SFSpeechLanguageModel.Configuration {
        let outputDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dynamicLanguageModel = outputDir.appendingPathComponent("LM")
        let dynamicVocabulary = outputDir.appendingPathComponent("Vocab")
        return SFSpeechLanguageModel.Configuration(languageModel: dynamicLanguageModel, vocabulary: dynamicVocabulary)
    }
    
    internal func startRecording() throws {

        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
            if #available(iOS 17, *) {
//                recognitionRequest.customizedLanguageModel = self.lmConfiguration
            }
        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                print("This text was understood by the panda: \(result.bestTranscription.formattedString)")
                isFinal = result.isFinal
                self.speechRecognized = result.bestTranscription.formattedString
            }
            
            if error != nil || isFinal {
                print("Audio recognition error: \(error?.localizedDescription)")
                
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        // FIXME: isRecording should only be true if audioEngine starts without failure
        self.isRecording = true
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    internal func stopRecording() {
        print("Stop recording")
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
    }
}
