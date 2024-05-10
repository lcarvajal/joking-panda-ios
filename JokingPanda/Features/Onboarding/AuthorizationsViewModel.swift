//
//  AuthorizationsViewModel.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 5/10/24.
//

import AVFoundation
import Foundation
import Speech
import UIKit

@Observable class AuthorizationsViewModel {
    internal var microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    internal var speechRecognizerStatus = SFSpeechRecognizer.authorizationStatus()
    internal var isAuthorizationRequired: Bool {
        return speechRecognizerStatus == .authorized && microphoneStatus == .authorized
    }
    
    internal func requestMicrophoneAccess() {
        switch microphoneStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { status in
                DispatchQueue.main.async {
                    self.microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
                }
            }
        case .denied:
            openSettings()
        default:
            return
        }
    }
    
    internal func requestSpeechRecognizerAccess() {
        switch speechRecognizerStatus {
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.speechRecognizerStatus = SFSpeechRecognizer.authorizationStatus()
                }
            }
        case .denied:
            openSettings()
        default:
            return
        }
    }
    
    private func openSettings() {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: {_ in
                DispatchQueue.main.async {
                    self.updateAuthorizationStatuses()
                }
            })
        }
    }
    
    private func updateAuthorizationStatuses() {
        speechRecognizerStatus = SFSpeechRecognizer.authorizationStatus()
        microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    }
}
