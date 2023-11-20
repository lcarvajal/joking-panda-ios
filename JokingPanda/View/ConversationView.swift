//
//  ConversationView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/8/23.
//

import SwiftUI

struct ConversationView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var showSheet = false
    @State var displayMessages = false
    @StateObject var conversationManager = ConversationManager()
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    AnimationView(geometry: .constant(geometry), status: $conversationManager.status)
                }
                .onTapGesture {
                    conversationManager.startConversation()
                }
            }
            .background(Color.tappableArea)
            
            MessagesView(displayMessages: $displayMessages, conversationManager: conversationManager)
                .background(Color.background)
        }
    }
}


#Preview {
    ConversationView()
}
