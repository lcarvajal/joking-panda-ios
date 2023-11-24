//
//  OverlayButtons.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/8/23.
//

import SwiftUI

struct ExitButton: View {
    @ObservedObject var speakAndListen: SpeakAndListen
    
    var body: some View {
        Button(action: {
            speakAndListen.conversationManager.selectedType = .deciding
            speakAndListen.updateAnimation(status: .stopped)
        }) {
            Label("", systemImage: "house.circle")
                .symbolRenderingMode(.palette)
                .font(.system(size: Constant.Size.button))
                .foregroundStyle(.tappableAccent)
                .padding()
                .padding(.top, 10)
        }
    }
}

struct PulsingTappingFinger: View {
    internal let size: CGFloat
    
    var body: some View {
        if #available(iOS 17.0, *) {
            Image(systemName: "hand.tap.fill")
                .symbolRenderingMode(.palette)
                .font(.system(size: size))
                .foregroundStyle(.white, .tappableAccent)
                .symbolEffect(.pulse, options: .repeating, isActive: true)
                .padding()
            
        } else {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: size))
                .foregroundStyle(.white, .tappableAccent)
                .padding()
        }
    }
}

struct SettingsButton: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        Button(action: {
            self.showSheet.toggle()
        }) {
            Label("", systemImage: "gear")
                .symbolRenderingMode(.palette)
                .font(.system(size: Constant.Size.button))
                .foregroundStyle(.tappableAccent)
                .padding()
                .padding(.top, 10)
        }
        .sheet(isPresented: $showSheet) {
            NavigationView {
                SettingsView()
            }
        }
    }
}
