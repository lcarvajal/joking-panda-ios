//
//  MenuButtons.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//

import SwiftUI

struct MenuButtons: View {
    @Binding var conversationType: ConversationType
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                conversationType = .journaling
            }) {
                Label("", systemImage: "book.closed.fill")
                    .symbolRenderingMode(.palette)
                    .font(.system(size: Constant.Size.button))
                    .foregroundStyle(.tappableAccent)
            }
            Spacer()
            Button(action: {
                conversationType = .dancing
            }) {
                Label("", systemImage: "figure.socialdance")
                    .symbolRenderingMode(.palette)
                    .font(.system(size: Constant.Size.button))
                    .foregroundStyle(.tappableAccent)
            }
            Spacer()
            Button(action: {
                conversationType = .joking
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

#Preview {
    MenuButtons(conversationType: Binding.constant(ConversationType.deciding))
}
