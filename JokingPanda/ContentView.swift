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
    
    @State var synthesizer = AVSpeechSynthesizer()
    @State var speechStatus = SFSpeechRecognizer.authorizationStatus()
    
    var body: some View {
        VStack {
            Text("🐼")
                .font(.headline)
                .fontWeight(.bold)
            
            switch speechStatus {
            case .authorized:
                Button("Start Panda") {
                    let utterance = PandaUtterance(string: "Hello, I'm The Joking Panda! Do you want to hear a joke?")
                    
                    // Tell the synthesizer to speak the utterance.
                    synthesizer.speak(utterance)
                }
            case .denied:
                Button("Enable your microphone in settings") {
                    // Open app settings
                    if let url = URL.init(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: {_ in 
                            speechStatus = SFSpeechRecognizer.authorizationStatus()
                        })
                    }
                }
            case .notDetermined:
                Button("Enable your microphone to talk to the panda") {
                    // Request access to microphone
                    SFSpeechRecognizer.requestAuthorization { status in
                        print("Updated speech status: \(status)")
                        speechStatus = SFSpeechRecognizer.authorizationStatus()
                    }
                }
            default:
                Text("Unfortunately talking panda only works for devices with a microphone.")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
