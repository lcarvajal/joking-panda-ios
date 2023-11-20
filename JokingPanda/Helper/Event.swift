//
//  Event.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 11/20/23.
//

import Foundation
import Mixpanel

struct Event {
    static func startConversation() {
#if DEBUG
        print("\(Constant.Event.conversationStarted) Event not tracked in DEBUG")
#else
        // Track conversation started
        Mixpanel.mainInstance().track(event: Constant.Event.conversationStarted,
                                      properties: [
                                        Constant.Event.Property.conversationId: conversations[conversationIndex].id
                                      ])
#endif
    }
}
