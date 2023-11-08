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

#Preview {
    OverlayedButtonsView()
}
