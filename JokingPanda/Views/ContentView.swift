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

            
            if speechStatus == .authorized && conversationManager.status == .stopped {
                Button("Listen to a Joke") {
                    conversationManager.startConversation()
                }
            }
            else if speechStatus == .authorized {
                Text("")
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
