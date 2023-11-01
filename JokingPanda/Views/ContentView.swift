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
    
    @State var speechStatus = SFSpeechRecognizer.authorizationStatus()
    @State var displayMessages = false
    @StateObject var conversationManager = ConversationManager()
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    AnimationView(geometry: .constant(geometry), image: AnimationManager.animationImageFor(conversationStatus: conversationManager.status))
                    
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if speechStatus == .authorized && conversationManager.status == .stopped {
                                if #available(iOS 17.0, *) {
                                    Image(systemName: "hand.tap.fill")
                                        .symbolRenderingMode(.palette)
                                        .font(.system(size: 50))
                                        .foregroundStyle(.white, .tappableAccent)
                                        .symbolEffect(.pulse, options: .repeating, isActive: true)
                                        .padding()
                                    
                                } else {
                                    // FIXME: This will look bad
                                    Image(systemName: "hand.tap.fill")
                                        .font(.system(size: 50))
                                        .padding()
                                }
                            }
                        }
                        .padding(10)
                    }
                }
                .background(Color.tappableArea)
                .onTapGesture {
                    if speechStatus == .authorized && conversationManager.status == .stopped {
                        conversationManager.startConversation()
                    }
                }
            }
            
            switch speechStatus {
            case .authorized:
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
                            Text(conversationManager.messageHistory)
                                .id(1)            // this is where to add an id
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .font(.system(size: 18, design: .rounded))
                                .frame(maxWidth: .infinity,
                                       alignment: .leading)
                        }
                        .background(Color.background)
                        .onChange(of: conversationManager.messageHistory) { _ in
                            proxy.scrollTo(1, anchor: .bottom)
                        }
                    }

                    UIView {
                        Text(conversationManager.speechOrPhraseToDisplay)
                            .font(.system(size: 26, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.backgroundLighter)
                    .cornerRadius(10)
                    .padding(.top, 0)
                }
                .frame(maxHeight: displayMessages ? .infinity : 180)
                .padding()
            default:
                // FIXME: This is broken on first app launch
                AuthorizationView()
            }
        }
        .background(Color.background)
    }
}

#Preview {
    ContentView(speechStatus: .authorized)
        .preferredColorScheme(.dark)
}
