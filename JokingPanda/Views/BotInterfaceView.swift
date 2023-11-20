//
//  BotInterfaceView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/8/23.
//

import SwiftUI

struct BotInterfaceView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var displayMessages = false
    @StateObject var conversationManager = ConversationManager()
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    AnimationView(geometry: .constant(geometry), status: $conversationManager.status)
                    
                    if conversationManager.status == .stopped {
                        OverlayedButtonsView(showSheet: $showSheet)
                    }
                }
                .onTapGesture {
                    conversationManager.startConversation()
                }
            }
            .background(Color.tappableArea)
            
            ConversationView(displayMessages: $displayMessages, conversationManager: conversationManager)
                .background(Color.background)
        }
    }
}


#Preview {
    BotInterfaceView()
}
