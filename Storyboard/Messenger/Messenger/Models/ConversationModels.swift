//
//  ConversationModels.swift
//  Messenger
//
//  Created by Ajin on 17/03/24.
//

import Foundation

struct Conversation{
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage{
    let date: String
    let text: String
    let isRead: Bool
}
