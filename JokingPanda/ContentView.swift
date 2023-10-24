//
//  ContentView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/23/23.
//

import SwiftUI
import Speech

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var speechStatus = SFSpeechRecognizer.authorizationStatus()
    
    @StateObject var speaker = Speaker()
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        VStack {
            Text("🐼")
                .font(.headline)
                .fontWeight(.bold)
            
            if !speaker.isSpeaking && !speechRecognizer.isRecording {
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
//                        do {
//                            try speechRecognizer.startRecording()
//                        }
//                        catch {
//                            print("Problem starting recording...")
//                        }
                    }
                }
            }
            else if speechRecognizer.isRecording {
                Text("Talk to the panda 😮")
                Button("I'm done talking") {
                    speechRecognizer.stopRecording()
                }
            }
            else {
                Text("Looks like we've got a bit of an error ❌")
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
