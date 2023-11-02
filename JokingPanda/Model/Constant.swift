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
        
        struct Key {
            
        }
        
        struct Value {
            
        }
    }
    
    struct Key {
        static let mixpanelProjectToken = "mixpanelProjectToken"
    }
    
    struct ImageName {
        static let pandaMicUpMouthOpen = "panda-mic-up-mouth-open"
        static let pandaMicUpMouthClosed = "panda-mic-up-mouth-closed"
        static let pandaMicDown = "panda-mic-down"
        static let pandaMicDownClosedEyes = "panda-mic-down-closed-eyes"
        
        static let pandaMicResting = "panda-mic-resting"
        static let pandaMicRestingEyesClosed = "panda-mic-resting-eyes-closed"
        static let pandaDance = "panda-dance"
    }
    
    struct Url {
        static let mixpanelServerUrl = "https://api-eu.mixpanel.com"
    }
}
