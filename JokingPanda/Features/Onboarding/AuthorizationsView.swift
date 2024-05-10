//
//  AuthorizationsView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/27/23.
//

import SwiftUI
import Speech

struct AuthorizationsView: View {
    internal var authorizationsViewModel: AuthorizationsViewModel
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                AnimationView(geometry: .constant(geometry), status: Binding.constant(AnimationAction.listening))
            }
            
            Spacer()
            
            Text("Talk to The Panda by enabling these settings")
                .multilineTextAlignment(.center)
                .padding()
            
            switch authorizationsViewModel.microphoneStatus {
            case .notDetermined, .denied:
                Button("Turn on microphone") {
                    authorizationsViewModel.requestMicrophoneAccess()
                }
                .buttonStyle(BigButtonStyle())
            case .restricted:
                Text("Your microphone is restricted on your device. Remove the restriction to speak to the panda 🥺.")
            case .authorized:
                Text("Microphone enabled ✅")
            @unknown default:
                Text("Unable to determine your microphone status.")
            }
            
            switch authorizationsViewModel.speechRecognizerStatus {
            case .notDetermined, .denied:
                Button("Turn on speech recognition") {
                    authorizationsViewModel.requestSpeechRecognizerAccess()
                }
                .buttonStyle(BigButtonStyle())
            case .restricted:
                Text("Speech recognition is restricted on your device. Remove the restriction to speak to the panda 🥺.")
            case .authorized:
                Text("Speech recognition enabled ✅")
            @unknown default:
                Text("Unable to determine your speech recognition status.")
            }
            Spacer()
        }
        .padding()
        .background(Color.background)
    }
}

