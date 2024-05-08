//
//  OverlayButtons.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/8/23.
//

import SwiftUI

struct OverlayButtons: View {
    @Binding var showSheet: Bool
    internal var botViewModel: BotViewModel
    internal let size: CGFloat
    
    var body: some View {
        VStack {
            if botViewModel.action == .stopped {
                HStack {
                    Spacer()
                    SettingsButton(showSheet: $showSheet)
                }
                Spacer()
                HStack {
                    Spacer()
                    PulsingTappingFinger(size: size)
                }
                .padding(10)
            }
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
