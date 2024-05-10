//
//  AuthorizationsModel.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 5/10/24.
//

import Foundation
import Speech
import AVFoundation

struct AuthorizationsModel {
    internal var audioRecorderStatus: AVAuthorizationStatus
    internal var microphoneStatus: AVAuthorizationStatus
    internal var speechRecognitionStatus: SFSpeechRecognizerAuthorizationStatus
    
    
    
//    private func requestAudioRecorderPermission() {
//        AVAudioApplication.requestRecordPermission { status in
//            audioRecorderStatus = status
//        }
//    }
//    
//    private func requestMicrophonePermission() { 
//        AVCaptureDevice.requestAccess(for: .audio) { status in
//            microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
//        }
//    }
//    
//    private func requestSpeechRecognitionPermission() {
//        SFSpeechRecognizer.requestAuthorization { status in
//            speechStatus = status
//        }
//    }
}
