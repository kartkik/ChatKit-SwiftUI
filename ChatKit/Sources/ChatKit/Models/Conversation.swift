//
//  Conversation.swift
//  ChatKit
//
//  Created by twixx  on 04/09/26.
//

import Foundation

public struct Conversation: Identifiable, Equatable {

    public let id: UUID
    public var title: String
    public var messages: [Message]

    public init(
        id: UUID = UUID(),
        title: String = "New Chat",
        messages: [Message] = []
    ) {
        self.id = id
        self.title = title
        self.messages = messages
    }
}
