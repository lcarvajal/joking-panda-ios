//
//  MainView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/27/23.
//

import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var conversationType: ConversationType
    @State var showSheet = false
    @State var displayMessages = false
    
    @StateObject var conversationManager = ConversationManager()
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    AnimationView(geometry: .constant(geometry), status: $conversationManager.status)
                    .background(getBackgroundColor())
                    .onTapGesture {
                        handleTapOnBot()
                    }
                    
                    VStack {
                        if conversationType == .deciding {
                            HStack {
                                Spacer()
                                SettingsButton(showSheet: $showSheet)
                            }
                            Spacer()
                        }
                        else {
                            HStack {
                                ExitButton(conversationType: $conversationType)
                                Spacer()
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                PulsingTappingFinger(size: 50)
                            }
                            .padding(10)
                        }
                    }
                }
            }
            
            switch conversationType {
            case .joking, .journaling:
                MessagesView(displayMessages: $displayMessages, conversationManager: conversationManager)
                    .background(Color.background)
                    .padding()
            default:
                MenuButtons(conversationType: $conversationType)
                    .frame(height: 100)
                    .padding()
            }
        }
        .background(Color.background)
    }
    
    private func getBackgroundColor() -> Color {
        switch conversationType {
        case .deciding:
            return Color.background
        default:
            return Color.tappableArea
        }
    }
    
    private func handleTapOnBot() {
        switch conversationType {
        case .joking:
            conversationManager.startConversation()
        default:
            return
        }
    }
}

#Preview {
    MainView(conversationType: .deciding)
}
