//
//  Animation.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/28/23.
//

import Foundation
import UIKit

struct Animation {
    static func animationImageFor(status: AnimationStatus) -> UIImage {
        let imageNames: [String]
        let duration: TimeInterval
        
        switch status {
        case .speaking:
            imageNames = AnimationImages.speakingPandaImageNames
            duration = 0.5
        case .listening:
            imageNames = AnimationImages.listeningPandaImageNames
            duration = 2
        case .dancing, .stopped:
            imageNames = AnimationImages.dancingPandaImageNames
            duration = 2
        }
        
        return animationImageFor(imageNames: imageNames, duration: duration)
    }
    
    static private func animationImageFor(imageNames: [String], duration: TimeInterval) -> UIImage {
        var images: [UIImage] = []
        
        for imageName in imageNames {
            if let image = UIImage(named: imageName) {
                images.append(image)
                
            }
        }
        
        if let animatedImage = UIImage.animatedImage(with: images, duration: duration) {
            return animatedImage
        }
        else {
            // FIXME: Not the most graceful solution to an image not existing
            return UIImage()
        }
    }
}

enum AnimationImages {
    static let dancingPandaImageNames = [
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicRestingEyesClosed,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicDown,
        Constant.ImageName.pandaDance,
        Constant.ImageName.pandaMicUpMouthClosed,
    ]
    
    static let listeningPandaImageNames = [
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMqicRestingEyesClosed
    ]
    
    static let speakingPandaImageNames = [
        Constant.ImageName.pandaMicUpMouthOpen,
        Constant.ImageName.pandaMicUpMouthClosed
    ]
}

enum AnimationStatus {
    case speaking
    case listening
    case dancing
    case stopped
}
