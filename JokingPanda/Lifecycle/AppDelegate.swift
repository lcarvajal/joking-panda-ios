//
//  AppDelegate.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/2/23.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    let defaults = UserDefaults.standard
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Event.configureEventTracking()
        Event.track(Constant.Event.appOpended)
        
        // Track if new version is opened
        let storedVersion = defaults.string(forKey: Constant.UserDefault.appVersion)
        if storedVersion == nil || storedVersion != currentVersion {
            // Set latest jokes for new users
            // UserDefaults.standard.set(1102, forKey: Constant.UserDefault.actId)
        }
        
        // Store current version
        defaults.set(currentVersion, forKey: Constant.UserDefault.appVersion)
        
        return true
    }
}
