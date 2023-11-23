//
//  AnimationView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/31/23.
//

import SwiftUI

struct AnimationView: UIViewRepresentable {
    @Binding var geometry: GeometryProxy
    @Binding var status: AnimationStatus
    
    internal func makeUIView(context: Self.Context) -> UIView {
        let parentView = UIView()
        parentView.autoresizesSubviews = true
        return parentView
    }

    internal func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AnimationView>) {
        uiView.subviews.forEach { $0.removeFromSuperview() }
        
        let image = Animation.animationImageFor(status: status)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.autoresizesSubviews = true
        imageView.frame = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
        
        uiView.addSubview(imageView)
    }
}

#Preview {
    GeometryReader { geometry in
        VStack {
//            AnimationView(geometry: .constant(geometry), status: .speaking)
//                .background(Color.skyBlue)
        }
    }
}
