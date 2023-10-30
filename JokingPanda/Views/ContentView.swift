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
    @StateObject var conversationManager = ConversationManager()
    
    var body: some View {
        VStack {
            Image(AnimationManager.performAnimation(conversationStatus: conversationManager.status))
                .resizable()
                .scaledToFit()
                .frame(height: 400)

            
            switch speechStatus {
            case .authorized:
                switch conversationManager.status {
                case .botSpeaking:
                    Text("🐼")
                    Text(conversationManager.currentPhrase())
                case .currentUserSpeaking:
                    Text("🎙️")
                    Text(conversationManager.speechRecognized)
                case .stopped:
                    Button("Listen to a Joke") {
                        conversationManager.startConversation()
                    }
                default:
                    Text("Conversation Going On")
                }
            default:
                // FIXME: This is broken on first app launch
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
