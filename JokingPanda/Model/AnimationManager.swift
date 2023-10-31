//
//  AnimationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/28/23.
//

import Foundation
import UIKit

struct AnimationManager {
    static private let talkingPandaImageNames = [
        Constant.ImageName.pandaMicUpMouthOpen,
        Constant.ImageName.pandaMicUpMouthClosed
    ]
    
    static func performAnimation(conversationStatus: ConversationStatus) -> String {
        let imageName: String
        
        switch conversationStatus {
        case .botSpeaking:
            imageName = Constant.ImageName.pandaMicUpMouthOpen
        case .currentUserSpeaking:
            imageName = Constant.ImageName.pandaMicResting
        case .noOneSpeaking:
            imageName = Constant.ImageName.pandaDance
        case .stopped:
            imageName = Constant.ImageName.pandaMicDown
        }
        
        return imageName
    }
    
    static func animationImageFor(conversationStatus: ConversationStatus) -> UIImage {
        switch conversationStatus {
        case .botSpeaking:
            return animationImageFor(imageNames: talkingPandaImageNames)!
        default:
            return animationImageFor(imageNames: [Constant.ImageName.pandaMicResting])!
        }
    }
    
    static private func animationImageFor(imageNames: [String]) -> UIImage? {
        var images: [UIImage] = []
        
        for imageName in imageNames {
            if let image = UIImage(named: imageName) {
                images.append(image)
                
            }
        }
        
        return UIImage.animatedImage(with: images, duration: 0.5)
    }
}
