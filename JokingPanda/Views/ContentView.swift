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
    
    @State var showSheet = false
    @State var speechStatus = SFSpeechRecognizer.authorizationStatus()
    @State var displayMessages = false
    @StateObject var conversationManager = ConversationManager()
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    AnimationView(geometry: .constant(geometry), status: $conversationManager.status)
                    
                    if conversationManager.status == .stopped {
                        OverlayedButtonsView(showSheet: $showSheet)
                    }
                }
                .background(Color.tappableArea)
                .onTapGesture {
                    if speechStatus == .authorized && conversationManager.status == .stopped {
                        conversationManager.startConversation()
                    }
                    else if speechStatus == .notDetermined {
                        AuthorizationView()
                    }
                }
            }
            
            ConversationView(displayMessages: $displayMessages, conversationManager: conversationManager)
                .background(Color.background)
        }
    }
}

#Preview {
    ContentView(speechStatus: .authorized)
        .preferredColorScheme(.dark)
}
