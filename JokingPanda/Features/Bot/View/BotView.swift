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
    @State var expandMessages = false
    @State var showSheet = false
    @State var showAlert = false
    
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
            
            if botViewModel.action == .listeningToLaugher {
                GaugeView(value: botViewModel.laughLoudness, maxValue: 5)
                    .padding()
            }
            else {
                MessagesView(displayMessages: $expandMessages, botViewModel: botViewModel)
                    .padding()
            }
            
        }
        .background(Color.background)
        .alert(isPresented: $showAlert) {
            // FIXME: - Alert is deprecated
            Alert(
                title: Text("Error"),
                message: Text(botViewModel.errorMessage),
                dismissButton: .default(Text("OK")) {
                    botViewModel.resetErrorMessage()
                }
            )
        }
        .onChange(of: botViewModel.errorMessage, { oldValue, newValue in
            if newValue.count > 0 {
                showAlert = true
            }
        })
    }
    
    private func handleTapOnBot() {
        if botViewModel.action == .stopped {
            botViewModel.startDialogue()
        }
        else {
            botViewModel.stopEverything()
        }
    }
}

#Preview {
    BotView(botViewModel: BotViewModel())
}
