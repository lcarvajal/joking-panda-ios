//
//  ConversationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/25/23.
//

import Foundation
import Mixpanel
import Speech

class ConversationManager: NSObject, ObservableObject {
    @Published var status: ConversationStatus = .stopped
    @Published var messageHistory: String = ""
    @Published var speechOrPhraseToDisplay = " "
    
    private var speechRecognized: String = ""
    private var phraseBotIsSaying: String = ""
    
    internal var currentPhrase: String {
        return conversations[conversationIndex].phrases[phraseIndex]
    }
    
    private var conversationIndex = 0
    private var phraseIndex = 0
    private var personToStartTalking: Person {
        return phraseIndex % 2 == 0 ? Person.bot : Person.currentUser
    }
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()
    private let conversations: [Conversation] = Tool.load("conversationData.json")
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private let synthesizer = AVSpeechSynthesizer()
    
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
        
        setConversationIndexOfLastConversation()
    }
    
    // MARK: - Setup
    
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
    
    private func setConversationIndexOfLastConversation() {
        let id = UserDefaults.standard.integer(forKey: Constant.UserDefault.conversationId)
        if let index = conversations.firstIndex(where: { $0.id == id }) {
            conversationIndex = index
        }
    }
    
    // MARK: - Actions
    
    internal func startConversation() {
        if self.messageHistory != "" {
            self.messageHistory += "\n"
        }
        
        activateAudioSession()
        status = .botSpeaking
        converse()
        
        // Track conversation started
        Mixpanel.mainInstance().track(event: Constant.Event.conversationStarted,
                                      properties: [
                                        Constant.Event.Property.conversationId: conversations[conversationIndex].id
                                      ])
    }
    
    private func converse() {
        // converse() is a recursive function that gets called again after the bot finishes speaking (in SpeechSynthesizerDelegate)
        // it also gets called again after the recording stops for a user
        
        if phraseIndex <= (conversations[conversationIndex].phrases.count - 1) && status != .stopped {
            if personToStartTalking == .bot {
                speak(currentPhrase)
                status = .botSpeaking
            }
            else {
                do {
                    print("Expected user phrase: \(currentPhrase)")
                    status = .currentUserSpeaking
                    
                    try startRecording()
                    stopRecordingAndHandleRecognizedPhrase()
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
            
            UserDefaults.standard.set(conversations[conversationIndex].id, forKey: Constant.UserDefault.conversationId)
        }
        print("Next phrase: \(conversations[conversationIndex].phrases[phraseIndex])")
    }
    
    private func updateSpeechOrPhraseToDisplay() {
        switch status {
        case .botSpeaking:
            speechOrPhraseToDisplay = "🐼 \(phraseBotIsSaying)"
        case .currentUserSpeaking:
            speechOrPhraseToDisplay = "🎙️ \(speechRecognized)"
        default:
            speechOrPhraseToDisplay = " "
        }
    }
}

extension ConversationManager: SFSpeechRecognizerDelegate {
    // MARK: - Actions
    
    private func startRecording() throws {
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        speechRecognized = ""
        updateSpeechOrPhraseToDisplay()
        
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.contextualStrings = currentPhrase.components(separatedBy: " ")
        
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
                self.updateSpeechOrPhraseToDisplay()
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
    
    private func stopRecordingAndHandleRecognizedPhrase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.speechRecognized.count < 1 {
                // If user hasn't said anything, wait on user input
                self.stopRecordingAndHandleRecognizedPhrase()
                return
            }
            else if Tool.levenshtein(aStr: self.speechRecognized, bStr: self.currentPhrase) < 5 {
                self.messageHistory += "\n🗣️ \(self.currentPhrase)"
            }
            else {
                self.messageHistory += "\n🗣️ \(self.speechRecognized)"
            }
            
            self.stopRecording()
            self.updateSpeechOrPhraseToDisplay()
            self.incrementPhraseIndex()
            self.converse()
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    // MARK: - SFSpeechRecognizerDelegate
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Availability of microphone changed: \(available)")
    }
}

extension ConversationManager: AVSpeechSynthesizerDelegate {
    // MARK: - Actions
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.45
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        
        self.synthesizer.speak(utterance)
    }
    
    private func stopSpeaking() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        phraseBotIsSaying = (utterance.speechString as NSString).substring(with: characterRange)
        updateSpeechOrPhraseToDisplay()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        stopSpeaking()
        if messageHistory == "" {
            messageHistory += "🐼 \(currentPhrase)"
        }
        else {
            messageHistory += "\n🐼 \(currentPhrase)"
        }
        incrementPhraseIndex()
        converse()
    }
}
