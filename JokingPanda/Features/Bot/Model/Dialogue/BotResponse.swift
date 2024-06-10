//
//  BotResponse.swift
//  JokingPanda
//
/**
 Determines whether to continue on in dialogue or to generate a custom response.
 For example, when a user doesn't respond "Who's there?" to a joke, the Bot Reponse `phrase` explains how knock knock jokes work.
 */

import Foundation

struct BotResponse {
    let phrase: String
    
    init(userPhraseWasExpected: Bool, expectedUserPhrase: String, nextBotPhrase: String) {
        if userPhraseWasExpected {
            phrase = nextBotPhrase
        }
        else {
            switch expectedUserPhrase {
            case ConstantPhrase.whosThere:
                self.phrase = ConstantPhrase.explainKnockKnock
            default:
                self.phrase = ConstantPhrase.couldYouRepeatWhatYouSaid
            }
        }
    }
}
