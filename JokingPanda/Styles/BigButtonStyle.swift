//
//  ButtonStyle.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/8/23.
//

import SwiftUI

struct BigButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(.tappableArea)
            .cornerRadius(10)
            .foregroundColor(.white)
            .font(.headline)
            .padding()
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
