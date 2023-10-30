//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation
import Speech

enum ConversationStatus {
    case botSpeaking
    case currentUserSpeaking
    case noOneSpeaking
    case stopped
}

class ConversationManager: NSObject, ObservableObject {
    @Published var status: ConversationStatus = .stopped
    @Published var speechRecognized: String = ""
    
    private var conversationIndex = 0
    private var phraseIndex = 0
    
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()
    private let conversations: [Conversation] = Tool.load("conversationData.json")
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))!
    private let synthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    
    @available(iOS 17, *)
    private var lmConfiguration: SFSpeechLanguageModel.Configuration {
        let outputDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dynamicLanguageModel = outputDir.appendingPathComponent("LM")
        let dynamicVocabulary = outputDir.appendingPathComponent("Vocab")
        return SFSpeechLanguageModel.Configuration(languageModel: dynamicLanguageModel, vocabulary: dynamicVocabulary)
    }
    
    override init() {
        super.init()
        synthesizer.delegate = self
        speechRecognizer.delegate = self
    }
    
    internal func startConversation() {
        activateAudioSession()
        status = .botSpeaking
        converse()
    }
    
    internal func currentPhrase() -> String {
        return conversations[conversationIndex].phrases[phraseIndex]
    }

    private func converse() {
        print("Phrase index: \(phraseIndex)")
        print(personToStartTalking())
        print("status: \(status)")
        
        if phraseIndex <= (conversations[conversationIndex].phrases.count - 1) && status != .stopped {
            if personToStartTalking() == .bot {
                speak(currentPhrase())
                status = .botSpeaking
            }
            else {
                do {
                    print("Expected user phrase: \(currentPhrase())")
                    status = .currentUserSpeaking
                    
                    try startRecording()
                    
                    // FIXME: - Logic for recording must go inside speech recognition function in order to create actions for different input
                    let seconds = 4.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        print("Recording stopped with this speech recognized: \(self.speechRecognized)")
                        self.stopRecording()
                        self.incrementPhraseIndex()
                        print("Start next part of conversation")
                        
                        self.converse()
                    }
                }
                catch {
                    print("Problem starting recording...")
                }
            }
        }
        else {
            return
        }
    }
    
    private func incrementPhraseIndex() {
        status = .noOneSpeaking
        phraseIndex += 1

        if phraseIndex > (conversations[conversationIndex].phrases.count - 1) {
            phraseIndex = 0
            conversationIndex += 1
            status = .stopped

            if conversationIndex > (conversations.count - 1) {
                conversationIndex = 0
                deactivateAudioSession()
            }
        }
        print("Next phrase: \(conversations[conversationIndex].phrases[phraseIndex])")
    }
    
    private func personToStartTalking() -> Person {
        return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser
    }
    
    private func activateAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .videoChat, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            print("Error activating audio session: \(error)")
        }
    }
    
    private func deactivateAudioSession() {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch {
            print("Error activating audio session: \(error)")
        }
    }
    
//    Functions for speaking out loud
    internal func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        
        // Assign the voice to the utterance.
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        self.synthesizer.speak(utterance)
    }
    
    internal func stopSpeaking() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
    
//    Functions for recording
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
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    internal func stopRecording() {
        print("Stop recording")
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}

extension ConversationManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Availability of microphone changed: \(available)")
    }
}

extension ConversationManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        stopSpeaking()
        incrementPhraseIndex()
        converse()
    }
}
