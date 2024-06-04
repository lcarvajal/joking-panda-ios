//
//  Bot.swift
//  JokingPanda
//
/*
 A bot holds all of the different components of haha panda together.
 It speaks, listens to user, then speaks again if needed, all while remembering the conversation.
 */

import Foundation
import Speech

protocol BotDelegate: AnyObject {
    func actionDidUpdate(action: AnimationAction)
    func currentPhraseDidUpdate(phrase: String)
    func errorDidOccur(error: Error)
    func phraseHistoryDidUpdate(phraseHistory: String)
    func laughLoudnessDidUpdate(loudness: Float)
}

class Bot: NSObject, ObservableObject  {
    internal weak var delegate: BotDelegate?
    
    private var action: AnimationAction = .stopped   // Animate based on current action
    private var brain: Brain    // Decides what to say and remembers what was said / heard
    private let audioPlayer: AudioPlayer
    private let laughRecognizer: LaughRecognizer
    private let speechRecognizer: SpeechRecognizer
    private var speechSynthesizer: SpeechSynthesizer    // Says phrases outloud
    
    init(audioPlayer: AudioPlayer = AudioPlayer(), laughRecognizer: LaughRecognizer = LaughRecognizer(), speechRecognizer: SpeechRecognizer = SpeechRecognizer(), mouth: SpeechSynthesizer = SpeechSynthesizer()) {
        let stageManager = StageManager.loadedWithJokes()
        self.brain = Brain(stageManager: stageManager)
        
        self.audioPlayer = audioPlayer
        self.laughRecognizer = laughRecognizer
        self.speechRecognizer = speechRecognizer
        self.speechSynthesizer = mouth
        
        super.init()
        
        audioPlayer.delegate = self
        laughRecognizer.delegate = self
        speechRecognizer.delegate = self
        mouth.delegate = self
    }
    
    /*
     Only needed if you don't want to use the default brain for the app.
     */
    internal func setBrain(_ brain: Brain) {
        self.brain = brain
    }
    
    /**
     Kick off conversation.
     */
    internal func startConversation() {
        brain.startConversation()
        let initalPhrase = brain.getInitalPhrase()
        speak(initalPhrase)
    }
    
    /**
     Stops speaking and listening.
     */
    internal func stopEverything() {
        action = .stopped
        brain.stopConversation()
        triggerActionUpdate()
        
        audioPlayer.stop()
        try? laughRecognizer.stop()
        speechSynthesizer.stop()
        speechRecognizer.stop()
    }
    
    /**
     Recursive function where the bot starts to speak, listens to a response, and speaks again if needed.
     */
    private func speak(_ phrase: String) {
        action = .speaking
        triggerActionUpdate()
        triggerCurrentPhraseUpdate(phrase: "", person: .bot)
        
        if let url = Tool.getAudioURL(for: phrase) {
            audioPlayer.start(url: url)
            triggerCurrentPhraseUpdate(phrase: phrase, person: .bot)
        }
        else {
            speechSynthesizer.speak(phrase: phrase)
        }
    }
    
    /**
     Sets action to listening, captures what a user says, adjusts it based on expected phrase, and remembers the phrase heard.
     */
    private func listen(expectedPhrase: String?) {
        action = .listening
        triggerActionUpdate()
        triggerCurrentPhraseUpdate(phrase: "", person: .currentUser)
        speechRecognizer.start(expectedPhrase: expectedPhrase)
    }
    
    private func listenForLaughter() {
        do {
            action = .listeningToLaugher
            triggerActionUpdate()
            triggerCurrentPhraseUpdate(phrase: "Laugh meter: 0", person: .currentUser)
            try laughRecognizer.start()
        }
        catch {
            delegate?.errorDidOccur(error: error)
        }
    }
    
    /**
     Depending on the conversation history and current conversation, this function calls `speak()` again or sets action to stop since the conversation is over.
     */
    private func respond() {
        if let phrase = brain.getResponse() {
            speak(phrase)
        }
        else {
            action = .stopped
            triggerActionUpdate()
        }
    }
    
    /**
     Trigger current phrase update for view model to show what is being said / heard.
     */
    private func triggerCurrentPhraseUpdate(phrase: String, person: Person) {
        let currentPhrase: String
        
        switch person {
        case .bot:
            currentPhrase = "🐼 \(phrase)"
        case .currentUser:
            currentPhrase = "🎙️ \(phrase)"
        }
        delegate?.currentPhraseDidUpdate(phrase: currentPhrase)
    }
    
    /**
     Trigger action update for view model to show different animations based on actions.
     */
    private func triggerActionUpdate() {
        delegate?.actionDidUpdate(action: action)
    }
    
    /**
     Trigger phrase history update for view model to show all phrases said / heard.
     */
    private func triggerPhraseHistoryUpdate() {
        delegate?.phraseHistoryDidUpdate(phraseHistory: brain.getPhraseHistory())
    }
}

extension Bot: LaughRecognizerDelegate {
    func laughRecognizerIsRecognizing(loudness: Float) {
        delegate?.laughLoudnessDidUpdate(loudness: loudness)
    }
    
    func laughRecognizerDidRecognize(loudness: Float) {
        brain.rememberLaughter(loudness: Int(loudness))
        
        delegate?.laughLoudnessDidUpdate(loudness: loudness)
        action = .stopped
        triggerActionUpdate()
        triggerPhraseHistoryUpdate()
    }
    
    func laughRecognizerErrorDidOccur(error: any Error) {
        delegate?.errorDidOccur(error: error)
    }
}

extension Bot: SpeechRecognizerDelegate {
    func speechRecognizerIsRecognizing(_ phrase: String) {
        triggerCurrentPhraseUpdate(phrase: phrase, person: .currentUser)
    }
    
    func speechRecognizerDidRecognize(_ phrase: String) {
        brain.remember(phrase, saidBy: .currentUser)
        
        action = .stopped
        triggerActionUpdate()
        triggerPhraseHistoryUpdate()
        
        respond()
    }
    
    func speechRecognizerErrorDidOccur(error: any Error) {
        delegate?.errorDidOccur(error: error)
    }
}

extension Bot: SpeechSynthesizerDelegate {
    func speechSynthesizerIsSayingPhrase(_ phrase: String) {
        triggerCurrentPhraseUpdate(phrase: phrase, person: .bot)
    }
    
    func speechSynthesizerDidSayPhrase(_ phrase: String) {
        brain.remember(phrase, saidBy: .bot)
        
        triggerPhraseHistoryUpdate()
        
        action = .stopped
        triggerActionUpdate()
        
        if !brain.wantsToStartNewJoke {
            listen(expectedPhrase: brain.getExpectedUserResponse())
        }
        else {
            listenForLaughter()
        }
    }
    
    func speechSynthesizerErrorDidOccur(error: any Error) {
        delegate?.errorDidOccur(error: error)
    }
}

extension Bot: AudioPlayerDelegate {
    func audioPlayerDidPlay() {
        if let phrase = brain.getResponse() {
            brain.remember(phrase, saidBy: .bot)
            triggerPhraseHistoryUpdate()
        }
        
        action = .stopped
        triggerActionUpdate()
        
        if !brain.wantsToStartNewJoke {
            listen(expectedPhrase: brain.getExpectedUserResponse())
        }
        else {
            listenForLaughter()
        }
    }
    
    func audioPlayerErrorDidOccur(error: Error) {
        delegate?.errorDidOccur(error: error)
    }
}
