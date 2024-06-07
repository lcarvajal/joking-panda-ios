//
//  Constant.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/31/23.
//

import Foundation

struct Constant {
    struct AppProperty {
        static bundleIdentifier = "com.JokingPanda"
    }
    
    struct Event {
        static let appOpended = "App Opened"
        static let conversationStarted = "Conversation Started"
        static let laughCaptured = "Laugh Captured"
        
        struct Property {
            static let actId = "Conversation Id"
            static let laughScore = "Laugh Score"
        }
    }
    
    struct FileName {
        static let knockKnockJokesJSON = "knockKnockJokeData.json"
    }
    
    struct FilePath {
        static let tempCustomLLMData = "/var/tmp/CustomLMDataForJokes.bin"
    }
    
    struct ImageName {
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
        static let appVersion = "appVersion"
        static let actId = "conversationId"
    }
    
    struct Url {
        static let mixpanelServerUrl = "https://api-eu.mixpanel.com"
    }
}
