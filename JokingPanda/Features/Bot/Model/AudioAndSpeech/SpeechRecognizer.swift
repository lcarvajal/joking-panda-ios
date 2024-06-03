//
//  SpeechRecognitionManager.swift
//  JokingPanda
//

import Foundation
import Speech

protocol SpeechRecognizerDelegate: AnyObject {
    func isRecognizing(_ phrase: String)
    func didRecognize(_ phrase: String)
}

class SpeechRecognizer: NSObject {
    internal weak var delegate: SpeechRecognizerDelegate?
    
    private let audioEngine: AVAudioEngine
    private var inputNode: AVAudioInputNode?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer
    
    private var expectedPhrase: String? = ""
    private var phraseHeard: String = ""
    private var isListening = false
    
    init(audioEngine: AVAudioEngine = AVAudioEngine(), speechRecognizer: SFSpeechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!) {
        self.audioEngine = audioEngine
        self.speechRecognizer = speechRecognizer
        
        super.init()
        speechRecognizer.delegate = self
    }
    
    internal func listen(expectedPhrase: String?) {
        phraseHeard = ""
        isListening = true
        self.expectedPhrase = expectedPhrase
        
        setUpSpeechRecognizer()
        captureSpeech(repeatedInterval: .seconds(3))
    }
    
    internal func stop() {
        isListening = false
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    // MARK: - Setup
    
    private func setUpSpeechRecognizer() {
        do {
            cancelRecognitionTask() // FIXME: - We probably can use isListening to rewrite this better
            inputNode = audioEngine.inputNode
            
            setUpRecognitionRequest()
            setUpRecognitionTask()
            setUpMicrophoneInput()
            
            audioEngine.prepare()
            try audioEngine.start()
        }
        catch {
            // FIXME: - Handle Error
            debugPrint("Error setting up speech recognizer audio engine: \(error)")
        }
    }
    
    private func setUpRecognitionRequest() {
        guard inputNode != nil else { return }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        if let expectedPhrase = self.expectedPhrase {
            recognitionRequest.contextualStrings = expectedPhrase.components(separatedBy: " ")
        }
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
    }
    
    private func setUpRecognitionTask() {
        setRecognitionTask { phraseHeard in
            if self.isListening {
                self.phraseHeard = phraseHeard
                self.delegate?.isRecognizing(phraseHeard)
            }
        } errorCompletion: { error in
            debugPrint("Error capturing speech: \(error.debugDescription)")
            self.stop()
        }
    }
    
    private func setUpMicrophoneInput() {
        guard let inputNode = inputNode else { return }
        
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
                self.delegate?.didRecognize(self.phraseHeard)
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
                // FIXME: Handle error
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

