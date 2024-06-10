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
    private var phraseHistory: PhraseHistory
    private var dialogueManager: DialogueManager
    
    private let audioPlayer: AudioPlayer
    private let laughRecognizer: LaughRecognizer
    private let speechRecognizer: SpeechRecognizer
    private var speechSynthesizer: SpeechSynthesizer    // Says phrases outloud
    
    init(audioPlayer: AudioPlayer = AudioPlayer(), dialogueHistory: PhraseHistory = PhraseHistory(), laughRecognizer: LaughRecognizer = LaughRecognizer(), speechRecognizer: SpeechRecognizer = SpeechRecognizer(), mouth: SpeechSynthesizer = SpeechSynthesizer()) {
        self.dialogueManager = DialogueManager.knockKnockJokesInstance()
        self.phraseHistory = PhraseHistory()
        
        self.audioPlayer = audioPlayer
        self.laughRecognizer = laughRecognizer
        self.speechRecognizer = speechRecognizer
        self.speechSynthesizer = mouth
        
        super.init()
        
        audioPlayer.delegate = self
        laughRecognizer.delegate = self
        speechRecognizer.delegate = self
        mouth.delegate = self
        
        dialogueManager.pickUpLastDialogueFromUserDefaults()
    }
    
    /*
     Only needed if you don't want to use the default brain for the app.
     */
    internal func setDialogeManager(_ dialogueManager: DialogueManager) {
        self.dialogueManager = dialogueManager
    }
    
    /**
     Kick off conversation.
     */
    internal func startDialogue() {
        dialogueManager.startDialogue()
        if let initalPhrase = dialogueManager.getBotPhrase() {
            speak(initalPhrase)
        }
    }
    
    /**
     Stops speaking and listening.
     */
    internal func stopEverything() {
        action = .stopped
        dialogueManager.queueNextDialogue()
        triggerActionUpdate()
        
        audioPlayer.stop()
        laughRecognizer.stop()
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
        action = .listeningToLaugher
        triggerActionUpdate()
        triggerCurrentPhraseUpdate(phrase: "Laugh meter: 0", person: .currentUser)
        laughRecognizer.start(for: .seconds(3))
    }
    
    /**
     Depending on the conversation history and current conversation, this function calls `speak()` again or sets action to stop since the conversation is over.
     */
    private func respond(to lastPhraseUserSaid: String) {
        if let phrase = dialogueManager.getBotPhrase() {
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
        delegate?.phraseHistoryDidUpdate(phraseHistory: phraseHistory.getHistory())
    }
}

extension Bot: LaughRecognizerDelegate {
    func laughRecognizerIsRecognizing(loudness: Float) {
        delegate?.laughLoudnessDidUpdate(loudness: loudness)
    }
    
    func laughRecognizerDidRecognize(loudness: Float) {
        phraseHistory.addLaughter(loudness: Int(loudness))
        
        delegate?.laughLoudnessDidUpdate(loudness: loudness)
        action = .stopped
        triggerActionUpdate()
        triggerPhraseHistoryUpdate()
        stopEverything()
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
        guard let expectedPhrase = dialogueManager.getExpectedUserPhrase() else {
            return
        }
        // Use expected phrase if it is close enough to user input
        let interpretedPhrase = Tool.levenshtein(aStr: phrase, bStr: expectedPhrase) < 5 ? expectedPhrase : phrase
        
        phraseHistory.addPhrase(interpretedPhrase, saidBy: .currentUser)
        
        action = .stopped
        triggerActionUpdate()
        triggerPhraseHistoryUpdate()
        
        dialogueManager.lastPhraseUserSaid = interpretedPhrase
        dialogueManager.moveOnInDialogueIfNeeded()
        respond(to: interpretedPhrase)
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
        phraseHistory.addPhrase(phrase, saidBy: .bot)
        triggerPhraseHistoryUpdate()
        
        action = .stopped
        triggerActionUpdate()
        
        if let expectedPhrase = dialogueManager.getExpectedUserPhrase() {
            listen(expectedPhrase: expectedPhrase)
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
        if let botPhrase = dialogueManager.getBotPhrase() {
            phraseHistory.addPhrase(botPhrase, saidBy: .bot)
            triggerPhraseHistoryUpdate()
        }
        
        action = .stopped
        triggerActionUpdate()
        
        if let expectedPhrase = dialogueManager.getExpectedUserPhrase() {
            listen(expectedPhrase: expectedPhrase)
        }
        else {
            listenForLaughter()
        }
    }
    
    func audioPlayerErrorDidOccur(error: Error) {
        delegate?.errorDidOccur(error: error)
    }
}
