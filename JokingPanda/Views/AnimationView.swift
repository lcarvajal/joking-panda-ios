//
//  AnimationView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/31/23.
//

import SwiftUI

struct AnimationView: UIViewRepresentable {
    @State var conversationStatus: ConversationStatus
    
    let parentWidth: CGFloat
    let parentHeight: CGFloat
    
    internal func makeUIView(context: Self.Context) -> UIView {
        let parentView = UIView()
        parentView.backgroundColor = .black
        parentView.layer.borderColor = Color.orange.cgColor
        parentView.autoresizesSubviews = true
        
        let animationImage = AnimationManager.animationImageFor(conversationStatus: conversationStatus)
        let imageView = UIImageView(image: animationImage)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.autoresizesSubviews = true
        imageView.backgroundColor = .orange
        imageView.frame = CGRect(x: 0, y: 0, width: parentWidth, height: parentHeight)
        parentView.addSubview(imageView)
        
        return parentView
    }

    internal func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AnimationView>) {
        
    }
}

#Preview {
    GeometryReader { geometry in
        VStack {
            Spacer()
            AnimationView(conversationStatus: .botSpeaking, parentWidth: geometry.size.width, parentHeight: geometry.size.height)
                .background(Color.green)
            
            Spacer()
        }
    }
}
