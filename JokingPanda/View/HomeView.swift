//
//  ContentView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/23/23.
//

import SwiftUI
import Speech

struct HomeView: View {
    @State var speechStatus = SFSpeechRecognizer.authorizationStatus()
    @State var microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    
    var body: some View {
        if microphoneStatus != .authorized || speechStatus != .authorized {
            AuthorizationsView(speechStatus: $speechStatus, microphoneStatus: $microphoneStatus)
        }
        else {
            MenuView()
        }
    }
}

#Preview {
    HomeView(speechStatus: .authorized)
        .preferredColorScheme(.dark)
}