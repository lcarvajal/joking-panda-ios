//
//  SettingsView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/8/23.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.requestReview) private var requestReview
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Feedback")) {
                    Button(action: {
                        if let emailURL = URL(string: "mailto:appsbylukas+hahapanda@gmail.com") {
                            if UIApplication.shared.canOpenURL(emailURL) {
                                UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
                            } else {
                                // Handle the case where the device can't open the email app (e.g., no email accounts configured).
                                // FIXME: No logic added here for user without email
                            }
                        }
                    }) {
                        Text("Send feedback")
                    }
                    Button(action: {
                        DispatchQueue.main.async {
                            requestReview()
                        }
                    }) {
                        Text("Review on The App Store")
                    }
                }
                
                //                Section(header: Text("Advanced Settings")) {
                //                    Button(action: {
                //                        // Add your action for the third button here
                //                    }) {
                //                        Text("Button 3")
                //                    }
                //                    Button(action: {
                //                        // Add your action for the fourth button here
                //                    }) {
                //                        Text("Button 4")
                //                    }
                //                }
            }
            .listStyle(GroupedListStyle()) // Apply a grouped list style
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


#Preview {
    SettingsView()
}
