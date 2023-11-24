//
//  Constant.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/31/23.
//

import Foundation

struct Constant {
    struct Event {
        static let appOpended = "App Opened"
        static let conversationStarted = "Conversation Started"
        
        struct Property {
            static let conversationId = "Conversation Id"
        }
    }
    
    struct ImageName {
        
        struct CoolPanda {
            static private let coolPanda = "cool-panda"
            static let handsDown = "\(coolPanda)-hands-down"
            static let oneArmWaveLeft = "\(coolPanda)-one-arm-wave-left"
            static let oneArmWaveRight = "\(coolPanda)-one-arm-wave-right"
            static let tiltLeft = "\(coolPanda)-tilt-left"
            static let tiltRight = "\(coolPanda)-tilt-right"
            static let twoArmWaveLeft = "\(coolPanda)-two-arm-wave-left"
            static let twoArmWaveRight = "\(coolPanda)-two-arm-wave-right"
            
        }
        
        struct SittingPanda {
            static private let sittingPanda = "sitting-panda"
            static let armRaisedMouthOpen = "\(sittingPanda)-arm-raised-mouth-open"
            static let armRaised = "\(sittingPanda)-arm-raised"
            static let armsDownHeadTilted = "\(sittingPanda)-arms-down-head-tilted"
            static let armsDown = "\(sittingPanda)-arms-down"
            static let eyesClosed = "\(sittingPanda)-eyes-closed"
        }
        
        struct TuxedoPanda {
            static private let tuxedoPanda = "tuxedo-panda"
            static let armRaised = "\(tuxedoPanda)-arm-raised"
            static let knock = "\(tuxedoPanda)-knock"
            static let micUpMouthOpen = "\(tuxedoPanda)-mic-up-mouth-open"
            static let micUpMouthClosed = "\(tuxedoPanda)-mic-up-mouth-closed"
            static let micDown = "\(tuxedoPanda)-mic-down"
            static let micDownClosedEyes = "\(tuxedoPanda)-mic-down-closed-eyes"
            static let micResting = "\(tuxedoPanda)-mic-resting"
            static let micRestingEyesClosed = "\(tuxedoPanda)-mic-resting-eyes-closed"
            static let dance = "\(tuxedoPanda)-dance"
        }
    }
    
    struct Size {
        static let button: CGFloat = 36
    }
    
    struct SensitiveKey {
        static let mixpanelProjectToken = "mixpanelProjectToken"
    }
    
    struct UserDefault {
        static let conversationId = "conversationId"
    }
    
    struct Url {
        static let mixpanelServerUrl = "https://api-eu.mixpanel.com"
    }
}
