//
//  AnimationManager.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/28/23.
//

import Foundation

struct AnimationManager {
    static func performAnimation(conversationStatus: ConversationStatus) -> String {
        let imageName: String
        
        switch conversationStatus {
        case .botSpeaking:
            imageName = "panda-mic-up-mouth-open"
        case .currentUserSpeaking:
            imageName = "panda-mic-resting"
        case .noOneSpeaking:
            imageName = "panda-dance"
        case .stopped:
            imageName = "panda-mic-down"
        }
        
        return imageName
    }
}
