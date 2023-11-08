//
//  SettingsButtonView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/8/23.
//

import SwiftUI

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

#Preview {
    SettingsButtonView()
}
