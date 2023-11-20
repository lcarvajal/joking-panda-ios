//
//  AppDelegate.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/2/23.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Event.configureEventTracking()
        Event.track(Constant.Event.appOpended)
        
        return true
    }
}
