//
//  OverlayedButtonsView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/8/23.
//

import SwiftUI

struct OverlayedButtonsView: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                SettingsButtonView(showSheet: $showSheet)
            }
            Spacer()
            HStack {
                Spacer()
                PulsingFingerTapView(size: 50)
            }
            .padding(10)
        }
    }
}

struct PulsingFingerTapView: View {
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

struct SettingsButtonView: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        Button(action: {
            self.showSheet.toggle()
        }) {
            Label("", systemImage: "gear")
                .symbolRenderingMode(.palette)
                .font(.system(size: 20))
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
