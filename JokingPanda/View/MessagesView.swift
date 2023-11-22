//
//  MessagesView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/8/23.
//

import SwiftUI

struct MessagesView: View {
    @Binding var displayMessages: Bool
    @ObservedObject var speakAndListen: SpeakAndListen
    
    var body: some View {
        VStack {
            Button {
                displayMessages.toggle()
            } label: {
                Image(systemName: displayMessages ? "chevron.compact.down" : "chevron.compact.up")
                    .imageScale(.large)
                    .foregroundStyle(.tappableAccent)
                    .padding(.bottom, 1)
                    .frame(maxWidth: .infinity)
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    Text(speakAndListen.conversationManager.conversationHistory)
                        .id(1)            // this is where to add an id
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .font(.system(size: 18, design: .rounded))
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                }
                .background(Color.background)
                .onChange(of: speakAndListen.conversationManager.conversationHistory) { _ in
                    proxy.scrollTo(1, anchor: .bottom)
                }
                .onChange(of: displayMessages) { _ in
                    proxy.scrollTo(1, anchor: .bottom)
                }
            }
            
            if speakAndListen.conversationManager.isConversing {
                HStack {
                    Text(speakAndListen.speechOrPhraseToDisplay)
                        .font(.system(size: 26, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                }
                .background(Color.backgroundLighter)
                .cornerRadius(10)
                .padding(.top, 0)
            }
        }
        .frame(maxHeight: displayMessages ? .infinity : 100)
    }
}
