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
        case .knocking:
            imageNames = AnimationImages.TuxedoPanda.knocking
            duration = 0.4
        case .listening:
            imageNames = AnimationImages.TuxedoPanda.listening
            duration = 2
        case .speaking:
            imageNames = AnimationImages.TuxedoPanda.speaking
            duration = 0.5
        case .dancing, .stopped:
            imageNames = AnimationImages.TuxedoPanda.dancing
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
    
    static func animationStatusFor(person: Person, phrase: String) -> AnimationStatus {
        switch person {
        case .bot:
            if phrase.contains("knock"){
                print("Should knock!")
                return .knocking
            }
            else {
                print("Just speaking!")
                return .speaking
            }
        case .currentUser:
            return .listening
        }
    }
}

enum AnimationImages {
    enum TuxedoPanda {
        static let dancing = [
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micRestingEyesClosed,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micDown,
            Constant.ImageName.TuxedoPanda.dance,
            Constant.ImageName.TuxedoPanda.micUpMouthClosed
        ]
        
        static let knocking = [
            Constant.ImageName.TuxedoPanda.armRaised,
            Constant.ImageName.TuxedoPanda.knock
        ]
        
        static let listening = [
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micResting,
            Constant.ImageName.TuxedoPanda.micRestingEyesClosed
        ]
        
        static let speaking = [
            Constant.ImageName.TuxedoPanda.micUpMouthOpen,
            Constant.ImageName.TuxedoPanda.micUpMouthClosed
        ]
    }
    
    
}

enum AnimationStatus {
    case speaking
    case knocking
    case listening
    case dancing
    case stopped
}
