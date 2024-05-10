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
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 20)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.value / self.maxValue) * geometry.size.width, geometry.size.width), height: 20)
                    .foregroundColor(Color.blue)
            }
        }
    }
}

#Preview {
    GaugeView(value: 50, maxValue: 100)
}
