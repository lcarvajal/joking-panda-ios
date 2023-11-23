//
//  Animation.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/28/23.
//

import Foundation
import UIKit

struct Animation {
    static private let talkingPandaImageNames = [
        Constant.ImageName.pandaMicUpMouthOpen,
        Constant.ImageName.pandaMicUpMouthClosed
    ]
    
    static private let dancingPandaImageNames = [
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
    
    static private let restingPandaImageNames = [
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicResting,
        Constant.ImageName.pandaMicRestingEyesClosed
    ]
    
    static func animationImageFor(status: AnimationStatus) -> UIImage {
        let imageNames: [String]
        let duration: TimeInterval
        
        switch status {
        case .speaking:
            imageNames = talkingPandaImageNames
            duration = 0.5
        case .listening:
            imageNames = restingPandaImageNames
            duration = 2
        case .dancing, .stopped:
            imageNames = dancingPandaImageNames
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

enum AnimationStatus {
    case speaking
    case listening
    case dancing
    case stopped
}
