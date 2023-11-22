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
                    .background(getBackgroundColor())
                    .onTapGesture {
                        handleTapOnBot()
                    }
                    
                    VStack {
                        if speakAndListen.conversationManager.selectedType == .deciding {
                            HStack {
                                Spacer()
                                SettingsButton(showSheet: $showSheet)
                            }
                            Spacer()
                        }
                        else if !speakAndListen.conversationManager.isConversing {
                            HStack {
                                ExitButton(speakAndListen: speakAndListen)
                                Spacer()
                            }
                            
                            Spacer()
                            
                            if speakAndListen.conversationManager.selectedType == .joking {
                                HStack {
                                    Spacer()
                                    PulsingTappingFinger(size: 50)
                                }
                                .padding(10)
                            }
                        }
                    }
                }
            }
            
            switch speakAndListen.conversationManager.selectedType {
            case .deciding:
                if !speakAndListen.conversationManager.isConversing {
                    MenuButtons(speakAndListen: speakAndListen)
                        .frame(height: 100)
                        .padding()
                }
                else {
                    MessagesView(displayMessages: $displayMessages, speakAndListen: speakAndListen)
                        .background(Color.background)
                        .padding()
                }
            case .joking:
                MessagesView(displayMessages: $displayMessages, speakAndListen: speakAndListen)
                    .background(Color.background)
                    .padding()
            default:
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 100)
                    .padding()
            }
        }
        .background(Color.background)
    }
    
    private func getBackgroundColor() -> Color {
        switch speakAndListen.conversationManager.selectedType {
        case .deciding, .joking:
            return Color.tappableArea
        default:
            return Color.background
        }
    }
    
    private func handleTapOnBot() {
        switch speakAndListen.conversationManager.selectedType {
        case .deciding:
            speakAndListen.startConversation(type: .deciding)
        case .joking:
            speakAndListen.startConversation(type: .joking)
        default:
            return
        }
    }
}

#Preview {
    MainView()
}
