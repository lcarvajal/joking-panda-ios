//
//  MainView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/27/23.
//

import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var showSheet = false
    @State var displayMessages = false
    
    @StateObject var speakAndListen = SpeakAndListen()
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    AnimationView(geometry: .constant(geometry), status: $speakAndListen.animationStatus)
                    .background(Color.background)
                    .onTapGesture {
                        handleTapOnBot()
                    }
                    
                    OverlayButtons(showSheet: $showSheet, speakAndListen: speakAndListen, size: 50)
                }
            }
            MessagesView(displayMessages: $displayMessages, speakAndListen: speakAndListen)
        }
        .background(Color.background)
    }
    
    private func handleTapOnBot() {
        if speakAndListen.conversationManager.isConversing {
            speakAndListen.stopConversation()
        }
        else {
            speakAndListen.startConversation()
        }
    }
}

#Preview {
    MainView()
}
