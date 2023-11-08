//
//  AuthorizationView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/27/23.
//

import SwiftUI
import Speech

struct AuthorizationsView: View {
    @State var speechStatus = SFSpeechRecognizer.authorizationStatus()
    @State var microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                AnimationView(geometry: .constant(geometry), status: Binding.constant(ConversationStatus.currentUserSpeaking))
            }
            
            Spacer()
            
            Text("Start talking to the panda by enabling these settings")
                .multilineTextAlignment(.center)
                .padding()
            
            switch microphoneStatus {
            case .notDetermined:
                Button("Turn on microphone") {
                    // Request access to microphone
                    AVCaptureDevice.requestAccess(for: .audio) { status in
                        microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
                    }
                }
                .buttonStyle(BigButtonStyle())
            case .denied:
                Button("Turn on microphone") {
                    // Open app settings
                    if let url = URL.init(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: {_ in
                            speechStatus = SFSpeechRecognizer.authorizationStatus()
                        })
                    }
                }
                .buttonStyle(BigButtonStyle())
            case .restricted:
                Text("Your microphone is restricted on your device. Remove the restriction to speak to the panda 🥺.")
            case .authorized:
                Text("Microphone enabled ✅")
            @unknown default:
                Text("Unable to determine your microphone status.")
            }
            
            switch speechStatus {
            case .notDetermined:
                Button("Turn on speech recognition") {
                    // Request access to speech recognition
                    SFSpeechRecognizer.requestAuthorization { status in
                        speechStatus = SFSpeechRecognizer.authorizationStatus()
                    }
                }
                .buttonStyle(BigButtonStyle())
            case .denied:
                Button("Turn on speech recognition") {
                    // Open app settings
                    if let url = URL.init(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: {_ in
                            speechStatus = SFSpeechRecognizer.authorizationStatus()
                        })
                    }
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
        .background(Color.backgroundLighter)
    }
}

#Preview {
    AuthorizationsView().preferredColorScheme(.dark)
}
