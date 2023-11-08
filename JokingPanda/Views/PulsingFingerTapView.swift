//
//  PulsingFingerTapView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/8/23.
//

import SwiftUI

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

#Preview {
    PulsingFingerTapView()
}
