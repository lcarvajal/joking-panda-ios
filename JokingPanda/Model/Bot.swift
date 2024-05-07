//
//  Bot.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 5/6/24.
//

import Foundation
import Speech

class Bot: NSObject, ObservableObject  {
    @Published var animation: AnimationStatus = .stopped
    @Published var phraseToDisplay: String = ""
    @Published var phraseHistory: String = ""
    
    private var phraseBotSaid: String = ""
    private var phraseBotHeard: String = ""
    
    private let audio = Audio()
    private let speechRecognizer = SpeechRecognizer()
    private let synthesizer = AVSpeechSynthesizer()
    
    internal func wait() {
        animation = .stopped
    }
    
    internal func speak(phrase: String) {
        // generateBotResponse
        audio.activateAudioSession()
        animation = .speaking
        playAudio(for: phrase)
    }
    
    internal func listen(expectedPhrase: String?) {
        phraseBotHeard = ""
        phraseToDisplay = ""
        animation = .listening
        setUpSpeechRecognizer(expectedPhrase: nil)
        activateSpeechRecognizer()
        stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: .seconds(3))
    }
}

extension Bot: AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    // MARK: - Speech Actions
    
    private func botSaid(_ phrase: String) {
        phraseBotSaid = phrase
        phraseToDisplay = "🐼 " + phraseBotSaid
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    private func playAudio(for phrase: String) {
        if let url = getAudioURL(for: phrase) {
            botSaid(phrase)
            audio.play(url: url, delegate: self)
        }
        else {
            // Fallback on voice synthesis if audio file doesn't exist
            self.synthesizer.botSpeak(string: phrase)
        }
    }
    
    private func getAudioURL(for phrase: String) -> URL? {
        let audioFileName = Tool.removePunctuation(from: phrase)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        return Bundle.main.url(forResource: audioFileName, withExtension: "m4a")
    }
    
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // FIXME: Handle successful and unsuccessful cases
        audio.deactivateAudioPlayer()
        phraseHistory += "\n🐼 " + phraseBotSaid
        // listen or wait()
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let phrase = (utterance.speechString as NSString).substring(with: characterRange)
        botSaid(phrase)
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        synthesizer.stopSpeaking(at: .immediate)
        phraseHistory += "\n🐼 " + phraseBotSaid
        // listen or wait()
    }
}

extension Bot: SFSpeechRecognizerDelegate {
    // MARK: - Listen Actions
    
    private func botHeard(_ phrase: String) {
        self.phraseBotHeard = phrase
        self.phraseToDisplay = "🎙️ " + phraseBotHeard
    }
    
    private func setUpSpeechRecognizer(expectedPhrase: String?) {
        speechRecognizer.setInputNode(inputNode: audio.audioEngine.inputNode)
        speechRecognizer.configure(expectedPhrase: expectedPhrase) { phraseBotHeard in
            self.botHeard(phraseBotHeard)
        } errorCompletion: { error in
            debugPrint("Error capturing speech: \(error.debugDescription)")
            self.audio.audioEngine.stop()
        }
        audio.audioEngine.prepare()
    }
    
    private func activateSpeechRecognizer() {
        do {
            try audio.audioEngine.start()
        }
        catch {
            // FIXME: - Handle Error
        }
    }
    
    private func stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: DispatchTimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + intervalsToRecognizeSpeech) {
            if self.phraseBotHeard.isEmpty {
                // If user hasn't said anything, delay stopping speech recognizer
                self.stopSpeechRecognizerAfterSpeechRecognized(intervalsToRecognizeSpeech: intervalsToRecognizeSpeech)
            }
            else {
                self.phraseHistory += "\n🗣️ " + self.phraseBotHeard
                self.audio.stopAudioEngine()
                self.speechRecognizer.stop()
            }
        }
    }
}
