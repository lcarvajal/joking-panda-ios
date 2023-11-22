//
//  MenuButtons.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//

import SwiftUI

struct MenuButtons: View {
    @ObservedObject var speakAndListen: SpeakAndListen
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                speakAndListen.startConversation(type: .journaling)
            }) {
                Label("", systemImage: "book.closed.fill")
                    .symbolRenderingMode(.palette)
                    .font(.system(size: Constant.Size.button))
                    .foregroundStyle(.tappableAccent)
            }
            Spacer()
            Button(action: {
                speakAndListen.startConversation(type: .dancing)
            }) {
                Label("", systemImage: "figure.socialdance")
                    .symbolRenderingMode(.palette)
                    .font(.system(size: Constant.Size.button))
                    .foregroundStyle(.tappableAccent)
            }
            Spacer()
            Button(action: {
                speakAndListen.startConversation(type: .joking)
            }) {
                Label("", systemImage: "face.smiling.fill")
                    .symbolRenderingMode(.palette)
                    .font(.system(size: Constant.Size.button))
                    .foregroundStyle(.tappableAccent)
            }
            Spacer()
        }
    }
}
