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
        parentView.autoresizesSubviews = true
        
        let animationImage = AnimationManager.animationImageFor(conversationStatus: conversationStatus)
        let imageView = UIImageView(image: animationImage)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.autoresizesSubviews = true
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
            AnimationView(conversationStatus: .botSpeaking, parentWidth: geometry.size.width, parentHeight: 150)
                .background(Color.skyBlue)
            AnimationView(conversationStatus: .currentUserSpeaking, parentWidth: geometry.size.width, parentHeight: 150)
                .background(Color.ebony)
            AnimationView(conversationStatus: .noOneSpeaking, parentWidth: geometry.size.width, parentHeight: 150)
                .background(Color.tappableArea)
        }
    }
}
