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

            
            if speechStatus == .authorized && !conversationManager.isConversing {
                Button("Listen to a Joke") {
                    conversationManager.converse()
                }
            }
            else if speechStatus == .authorized && conversationManager.isConversing {
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
