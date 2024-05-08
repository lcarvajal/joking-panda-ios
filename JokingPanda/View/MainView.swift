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
    
    @StateObject var bot = Bot()
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    AnimationView(geometry: .constant(geometry), status: $bot.action)
                    .background(Color.tappableArea)
                    .onTapGesture {
                        handleTapOnBot()
                    }
                    
                    OverlayButtons(showSheet: $showSheet, bot: bot, size: 50)
                }
            }
            MessagesView(displayMessages: $displayMessages, bot: bot, ear: bot.ear, mouth: bot.mouth)
        }
        .background(Color.background)
    }
    
    private func handleTapOnBot() {
        if bot.action == .stopped {
            bot.startConversation()
        }
        else {
            bot.stopEverything()
        }
    }
}

#Preview {
    MainView()
}
