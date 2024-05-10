//
//  JokingPandaApp.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/23/23.
//

import SwiftUI

@main
struct JokingPandaApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            BaseView(authorizationsViewModel: AuthorizationsViewModel()).statusBar(hidden: true)
        }
    }
}
