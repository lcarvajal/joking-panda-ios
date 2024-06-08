//
//  BotResponsePhrase.swift
//  JokingPanda
//
/**
 Determines whether to continue on in dialogue or to generate a custom response.
 For example, when a user doesn't respond "Who's there?" to a joke, the Bot Reponse `phrase` explains how knock knock jokes work.
 */

import Foundation

struct BotResponse {
    let phrase: String
    
    init(userSaidSomethingExpected: Bool, nextPhraseInDialog: String) {
        if userSaidSomethingExpected {
            phrase = nextPhraseInDialog
        }
        else {
            switch nextPhraseInDialog {
            case ConstantLine.whosThere:
                self.phrase = ConstantLine.explainKnockKnock
            default:
                self.phrase = ConstantLine.couldYouRepeatWhatYouSaid
            }
        }
    }
}
