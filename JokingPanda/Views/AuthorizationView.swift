//
//  AuthorizationView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/27/23.
//

import SwiftUI
import Speech

struct AuthorizationView: View {
    @State var speechStatus = SFSpeechRecognizer.authorizationStatus()
    
    var body: some View {
        switch speechStatus {
        case .denied:
            Button("Open settings to turn on your microphone") {
                // Open app settings
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: {_ in
                        speechStatus = SFSpeechRecognizer.authorizationStatus()
                    })
                }
            }
        case .notDetermined:
            Button("Talk to the panda") {
                // Request access to microphone
                SFSpeechRecognizer.requestAuthorization { status in
                    speechStatus = SFSpeechRecognizer.authorizationStatus()
                }
            }
        case .restricted:
            Text("There seems to be a problem accessing your microphone. It doesnt look like you can speak to the panda 🥺.")
        default:
            EmptyView()
        }
    }
}

#Preview {
    AuthorizationView()
}
