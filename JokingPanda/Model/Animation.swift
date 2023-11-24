//
//  Animation.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/28/23.
//

import Foundation
import UIKit

struct Animation {
    static func animationImageFor(character: AnimationCharacter, status: AnimationStatus) -> UIImage {
        switch character {
        case .coolPanda:
            return animationImagesForCoolPanda(status: status)
        case .sittingPanda:
            return animationImagesForSittingPanda(status: status)
        case .tuxedoPanda:
            return animationImagesForTuxedoPanda(status: status)
        }
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
    
    static private func animationImagesForCoolPanda(status: AnimationStatus) -> UIImage {
        let imageNames: [String]
        let duration: TimeInterval
        
        switch status {
        case .dancing:
            imageNames = AnimationImages.CoolPanda.dancing
            duration = 5
        case .stopped, .listening:
            imageNames = AnimationImages.CoolPanda.waiting
            duration = 2
        default:
            imageNames = AnimationImages.SittingPanda.listening
            duration = 2
        }
        
        return animationImageFor(imageNames: imageNames, duration: duration)
    }
    
    static private func animationImagesForSittingPanda(status: AnimationStatus) -> UIImage {
        let imageNames: [String]
        let duration: TimeInterval
        
        switch status {
        case .listening:
            imageNames = AnimationImages.SittingPanda.listening
            duration = 2
        case .speaking:
            imageNames = AnimationImages.SittingPanda.speaking
            duration = 0.5
        default:
            imageNames = AnimationImages.SittingPanda.listening
            duration = 2
        }
        
        return animationImageFor(imageNames: imageNames, duration: duration)
    }
    
    static private func animationImagesForTuxedoPanda(status: AnimationStatus) -> UIImage {
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
}

enum AnimationImages {
    enum CoolPanda {
        static let dancing = [
            Constant.ImageName.CoolPanda.handsDown,
            Constant.ImageName.CoolPanda.oneArmWaveLeft,
            Constant.ImageName.CoolPanda.oneArmWaveRight,
            Constant.ImageName.CoolPanda.oneArmWaveLeft,
            Constant.ImageName.CoolPanda.oneArmWaveRight,
            Constant.ImageName.CoolPanda.oneArmWaveLeft,
            Constant.ImageName.CoolPanda.oneArmWaveRight,
            Constant.ImageName.CoolPanda.tiltLeft,
            Constant.ImageName.CoolPanda.tiltRight,
            Constant.ImageName.CoolPanda.twoArmWaveLeft,
            Constant.ImageName.CoolPanda.twoArmWaveRight,
            Constant.ImageName.CoolPanda.twoArmWaveLeft,
            Constant.ImageName.CoolPanda.twoArmWaveRight,
            Constant.ImageName.CoolPanda.twoArmWaveLeft,
            Constant.ImageName.CoolPanda.twoArmWaveRight,
            Constant.ImageName.CoolPanda.tiltLeft,
            Constant.ImageName.CoolPanda.tiltRight
        ]
        
        static let waiting = [
            Constant.ImageName.CoolPanda.handsDown,
            Constant.ImageName.CoolPanda.handsDown,
            Constant.ImageName.CoolPanda.handsDown,
            Constant.ImageName.CoolPanda.handsDown,
            Constant.ImageName.CoolPanda.handsDown,
            Constant.ImageName.CoolPanda.handsDown,
            Constant.ImageName.CoolPanda.tiltLeft
        ]
    }
    
    enum SittingPanda {
        static let listening = [
            Constant.ImageName.SittingPanda.armsDown,
            Constant.ImageName.SittingPanda.armsDown,
            Constant.ImageName.SittingPanda.armsDownHeadTilted,
            Constant.ImageName.SittingPanda.armsDown,
            Constant.ImageName.SittingPanda.armsDown,
            Constant.ImageName.SittingPanda.armsDown,
            Constant.ImageName.SittingPanda.eyesClosed
        ]
        
        static let speaking = [
            Constant.ImageName.SittingPanda.armRaised,
            Constant.ImageName.SittingPanda.armRaisedMouthOpen
        ]
    }
    
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

enum AnimationCharacter {
    case coolPanda
    case sittingPanda
    case tuxedoPanda
}

enum AnimationStatus {
    case speaking
    case knocking
    case listening
    case dancing
    case stopped
}
