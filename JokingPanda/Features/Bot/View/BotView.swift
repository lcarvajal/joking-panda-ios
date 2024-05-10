//
//  MainView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/27/23.
//

import SwiftUI

struct BotView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var botViewModel: BotViewModel
    @State var displayMessages = false
    @State var showSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    AnimationView(geometry: .constant(geometry), status: $botViewModel.action)
                    .background(Color.tappableArea)
                    .onTapGesture {
                        handleTapOnBot()
                    }
                    
                    OverlayButtons(showSheet: $showSheet, botViewModel: botViewModel, size: 50)
                }
            }
            MessagesView(displayMessages: $displayMessages, botViewModel: botViewModel).padding()
            
        }
        .background(Color.background)
    }
    
    private func handleTapOnBot() {
        if botViewModel.action == .stopped {
            botViewModel.startConversation()
        }
        else {
            botViewModel.stopEverything()
        }
    }
}
