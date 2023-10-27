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
    
    var body: some View {
        VStack {
            Image(pandaImageToDisplay)
                .resizable()
                .scaledToFit()
                .frame(height: 400)

            
            if speechStatus == .authorized {
                if conversationManager.personToStartTalking() == .currentUser && !conversationManager.speechRecognizer.isRecording {
                    Button("Respond to Panda") {
                        pandaImageToDisplay = "panda-mic-down"
                        conversationManager.listen()
                    }
                }
                else if conversationManager.personToStartTalking() == .currentUser && conversationManager.speechRecognizer.isRecording {
                    Button("I'm done talking") {
                        conversationManager.stopListening()
                        
                        pandaImageToDisplay = "panda-mic-up-mouth-open"
                        conversationManager.speak()
                    }
                }
                else {
                    Button("Listen to Panda") {
                        pandaImageToDisplay = "panda-mic-up-mouth-open"
                        conversationManager.speak()
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
