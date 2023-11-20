//
//  AuthorizationView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/27/23.
//

import SwiftUI

struct MenuView: View {
    @State var showSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    ZStack {
                        AnimationView(geometry: .constant(geometry), status: Binding.constant(ConversationStatus.noOneSpeaking))
                        VStack {
                            HStack {
                                Spacer()
                                SettingsButtonView(showSheet: $showSheet)
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                NavigationLink(destination: ConversationView()) {
                                    Image(systemName: "book.closed.fill") // System icon
                                                                .font(.system(size: 36))
                                                                .foregroundColor(.tappableAccent)
                                                                .symbolRenderingMode(.palette)
                                }
                                Spacer()
                                NavigationLink(destination: ConversationView()) {
                                    Image(systemName: "music.quarternote.3") // System icon
                                                                .font(.system(size: 36))
                                                                .foregroundColor(.tappableAccent)
                                                                .symbolRenderingMode(.palette)
                                }
                                Spacer()
                                NavigationLink(destination: ConversationView()) {
                                    Image(systemName: "figure.socialdance") // System icon
                                                                .font(.system(size: 36))
                                                                .foregroundColor(.tappableAccent)
                                                                .symbolRenderingMode(.palette)
                                }
                                Spacer()
                                NavigationLink(destination: ConversationView()) {
                                    Image(systemName: "face.smiling.fill") // System icon
                                                                .font(.system(size: 36))
                                                                .foregroundColor(.tappableAccent)
                                                                .symbolRenderingMode(.palette)
                                }
                                Spacer()
                            }
                            .padding()
                            .padding(.bottom, 10)
                        }
                    }
                }
            }
            .background(Color.background)
        }
    }
}

#Preview {
    MenuView()
}
