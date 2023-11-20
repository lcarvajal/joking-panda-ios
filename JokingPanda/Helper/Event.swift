//
//  Event.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/20/23.
//

import Foundation
import Mixpanel

struct Event {
    static func configureEventTracking() {
        #if DEBUG
            print("Event tracking not enabled in DEBUG")
        #else
            if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"), let keys = NSDictionary(contentsOfFile: path),
               let mixpanelProjectToken = keys[Constant.SensitiveKey.mixpanelProjectToken] as? String {
                let mixpanel = Mixpanel.initialize(token: mixpanelProjectToken, trackAutomaticEvents: true)
                mixpanel.serverURL = Constant.Url.mixpanelServerUrl
            }
            else {
                // FIXME: Handle mixpanel not getting configured
            }
        #endif
    }
    
    static func track(_ event: String, properties: Properties? = nil) {
        #if DEBUG
            print("\(event) Event not tracked in DEBUG")
        #else
            Mixpanel.mainInstance().track(event: event, properties: properties)
        #endif
    }
}
