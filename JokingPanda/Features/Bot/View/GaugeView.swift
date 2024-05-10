//
//  GaugeView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 5/10/24.
//

import SwiftUI

struct GaugeView: View {
    var value: Float
    var maxValue: Float
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Laugh Score: \(Int(value)) / 5")
                .font(.system(size: 26, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 20)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(self.value / self.maxValue) * geometry.size.width, geometry.size.width), height: 20)
                        .foregroundColor(Color.tappableAccent)
                }
            }
        }
        .background(Color.background)
        .frame(maxHeight: 100)
    }
}

#Preview {
    GaugeView(value: 3, maxValue: 5)
}
