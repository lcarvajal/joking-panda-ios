//
//  ContentView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/23/23.
//

import SwiftUI
import AVFoundation
import Speech

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var speechStatus = SFSpeechRecognizer.authorizationStatus()
//    @State var isRecording = false
    
    @StateObject var speaker = Speaker()
    
    var body: some View {
        VStack {
            Text("🐼")
                .font(.headline)
                .fontWeight(.bold)
            
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
                        print("Updated speech status: \(status)")
                        speechStatus = SFSpeechRecognizer.authorizationStatus()
                    }
                }
            case .restricted:
                Text("There seems to be a problem accessing your microphone. It doesnt look like you can speak to the panda 🥺.")
            default:
                Button("Start Panda") {
                    speaker.speak("Hello, I'm The Joking Panda! Do you want to hear a joke?")
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
