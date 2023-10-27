//
//  ContentView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/23/23.
//

import SwiftUI
import Speech

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var speechStatus = SFSpeechRecognizer.authorizationStatus()
    @State var conversationManager = ConversationManager()
    @State var pandaImageToDisplay = "panda-mic-resting"
    
    @StateObject var speaker = Speaker()
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        VStack {
            Image(pandaImageToDisplay)
                .resizable()
                .scaledToFit()
                .frame(height: 400)

            
            if speechStatus == .authorized {
                if conversationManager.personToStartTalking() == .currentUser && !speechRecognizer.isRecording {
                    Button("Respond to Panda") {
                        do {
                            print("Expected user phrase: \(conversationManager.currentPhrase())")
                            speaker.stop()
                            pandaImageToDisplay = "panda-mic-down"
                            try speechRecognizer.startRecording()
                        }
                        catch {
                            print("Problem starting recording...")
                        }
                    }
                }
                else if conversationManager.personToStartTalking() == .currentUser && speechRecognizer.isRecording {
                    Button("I'm done talking") {
                        speechRecognizer.stopRecording()
                        conversationManager.incrementPhraseIndex()
                        
                        pandaImageToDisplay = "panda-mic-up-mouth-open"
                        speaker.speak(conversationManager.currentPhrase())
                        conversationManager.incrementPhraseIndex()
                    }
                }
                else {
                    Button("Listen to Panda") {
                        pandaImageToDisplay = "panda-mic-up-mouth-open"
                        speaker.speak(conversationManager.currentPhrase())
                        conversationManager.incrementPhraseIndex()
                    }
                }
            }
            else {
                AuthorizationView()
            }
        }
        .padding()
        .background(Color.gray)
    }
}

#Preview {
    ContentView()
}
