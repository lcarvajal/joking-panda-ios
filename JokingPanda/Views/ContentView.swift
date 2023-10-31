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
    @StateObject var conversationManager = ConversationManager()
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    switch conversationManager.status {
                    case .botSpeaking:
                        AnimationView(conversationStatus: conversationManager.status, parentWidth: geometry.size.width, parentHeight: geometry.size.height)
                    default:
                        AnimationView(conversationStatus: conversationManager.status, parentWidth: geometry.size.width, parentHeight: geometry.size.height)
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if speechStatus == .authorized && conversationManager.status == .stopped {
                                if #available(iOS 17.0, *) {
                                    Image(systemName: "hand.tap.fill")
                                        .symbolRenderingMode(.palette)
                                        .font(.system(size: 50))
                                        .foregroundStyle(.white, .blue)
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
                .onTapGesture {
                    if speechStatus == .authorized && conversationManager.status == .stopped {
                        conversationManager.startConversation()
                    }
                }
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    Text(conversationManager.messageHistory)
                        .id(1)            // this is where to add an id
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .font(.system(size: 26, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .onChange(of: conversationManager.messageHistory) { _ in
                    proxy.scrollTo(1, anchor: .bottom)
                }
            }
            
            switch speechStatus {
            case .authorized:
                switch conversationManager.status {
                case .botSpeaking:
                    Text("🐼 \(conversationManager.phraseBotIsSaying)")
                        .font(.system(size: 26, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                case .currentUserSpeaking:
                    Text("🎙️ \(conversationManager.speechRecognized)")
                        .font(.system(size: 26, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                default:
                    Text("")
                        .font(.system(size: 26, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                }
            default:
                // FIXME: This is broken on first app launch
                AuthorizationView()
            }
        }
    }
}

#Preview {
    ContentView(speechStatus: .authorized)
}
