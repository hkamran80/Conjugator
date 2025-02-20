//
//  Conversation.swift
//  Conjugator
//
//  Created by Zheng on 2/13/23.
//

import SwiftUI

struct Conversation: Identifiable {
    let id = UUID()
    var challenge: Challenge
    var correctForm: Form
    var showingChoices = false
    var choices: [Choice]
    var selectedChoice: Choice?
    var strikethroughChoices = [Choice]()
    var status = Status.questionAsked
    var messages = [Message]()

    enum Status: Equatable {
        case questionAsked
        case questionAnsweredCorrectly(numberOfAttempts: Int)

        var complete: Bool {
            switch self {
            case .questionAsked:
                return false
            case .questionAnsweredCorrectly:
                return true
            }
        }
    }
}
