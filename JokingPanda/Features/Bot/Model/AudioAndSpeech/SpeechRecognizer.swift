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
    
    private var inputNode: AVAudioInputNode?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var phraseHeard: String = ""
    private var isListening = false
    private let audioEngine: AVAudioEngine
    
    init(audioEngine: AVAudioEngine = AVAudioEngine()) {
        self.audioEngine = audioEngine
        super.init()
        speechRecognizer.delegate = self
    }
    
    internal func listen(expectedPhrase: String?) {
        phraseHeard = ""
        isListening = true
        setUpSpeechRecognizer(expectedPhrase: expectedPhrase)
        startSpeechRecognizer()
        stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: .seconds(3))
    }
    
    internal func stop() {
        isListening = false
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    // MARK: - Setup
    
    private func configureMicrophoneInput() {
        guard let inputNode = inputNode else { return }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
    }
    
    private func configureRecognitionRequest(expectedPhrase: String?) {
        guard let inputNode = inputNode else { return }
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        if let expectedPhrase = expectedPhrase {
            recognitionRequest.contextualStrings = expectedPhrase.components(separatedBy: " ")
        }
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        
    }
    
    // MARK: - Actions
    
    internal func configure(expectedPhrase: String?, completion: @escaping ((String) -> Void), errorCompletion: @escaping ((any Error)?) -> Void) {
        cancelCurrentRecognitionTask()
        configureRecognitionRequest(expectedPhrase: expectedPhrase)
        setRecognitionTask(completion: completion, errorCompletion: errorCompletion)
        configureMicrophoneInput()
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
    
    // MARK: - Listen Actions
    private func startSpeechRecognizer() {
        do {
            audioEngine.prepare()
            try audioEngine.start()
        }
        catch {
            // FIXME: - Handle Error
            debugPrint("Error setting up speech recognizer audio engine: \(error)")
        }
    }
    
    private func setUpSpeechRecognizer(expectedPhrase: String?) {
        inputNode = audioEngine.inputNode
        configure(expectedPhrase: expectedPhrase) { phraseHeard in
            if self.isListening {
                self.phraseHeard = phraseHeard
                self.delegate?.isRecognizing(phraseHeard)
            }
        } errorCompletion: { error in
            debugPrint("Error capturing speech: \(error.debugDescription)")
            self.stop()
        }
    }
    
    private func stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: DispatchTimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + intervalsToRecognizeSpeech) {
            if self.phraseHeard.isEmpty && self.isListening {
                // If user hasn't said anything, delay stopping speech recognizer
                self.stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: intervalsToRecognizeSpeech)
            }
            else if self.isListening {
                self.delegate?.didRecognize(self.phraseHeard)
                self.stop()
            }
        }
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        <#code#>
//    }
}

