//
//  Message.swift
//  ChatKit
//
//  Created by twixx  on 04/09/26.
//

import Foundation

public struct Message: Identifiable, Equatable, Sendable {

    public enum Role: Equatable, Sendable {
        case user
        case assistant
    }

    public enum StreamState: Equatable, Sendable {
        case complete
        case streaming
    }

    public let id: UUID
    public let role: Role
    public var text: String
    public let timestamp: Date
    public var streamState: StreamState

    public init(
        id: UUID = UUID(),
        role: Role,
        text: String = "",
        timestamp: Date = Date(),
        streamState: StreamState = .complete
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
        self.streamState = streamState
    }
}
