//
//  DanceView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/21/23.
//

import SwiftUI

struct DanceView: View {
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    AnimationView(geometry: .constant(geometry), status: Binding.constant(AnimationStatus.dancing))
                }
            }
        }
        .background(Color.background)
    }
}

#Preview {
    DanceView()
}
