//
//  AppDelegate.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/2/23.
//

import Foundation
import UIKit
import Mixpanel

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        configureAppEventTracking()
        Mixpanel.mainInstance().track(event: Constant.Event.appOpended)
        
        return true
    }
    
    private func configureAppEventTracking() {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"), let keys = NSDictionary(contentsOfFile: path),
           let mixpanelProjectToken = keys[Constant.SensitiveKey.mixpanelProjectToken] as? String {
            let mixpanel = Mixpanel.initialize(token: mixpanelProjectToken, trackAutomaticEvents: true)
            mixpanel.serverURL = Constant.Url.mixpanelServerUrl
        }
        else {
            // FIXME: Handle mixpanel not getting configured
        }
    }
}
