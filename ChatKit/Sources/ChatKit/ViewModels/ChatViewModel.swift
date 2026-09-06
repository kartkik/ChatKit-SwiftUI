//
//  ChatViewModel.swift
//  ChatKit
//
//  Created by twixx  on 04/09/26.
//

import Foundation
import Observation

@MainActor
@Observable
public final class ChatViewModel {

    public private(set) var conversation: Conversation
    public private(set) var isStreaming: Bool = false
    public var inputText: String = ""

    public var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isStreaming
    }

    private let service: ChatServiceProtocol
    private let greeting: String
    private var streamingTask: Task<Void, Never>?

    public init(
        service: ChatServiceProtocol = MockChatService(),
        greeting: String = "Hello! 👋 I'm your AI assistant. Ask me anything about Swift, SwiftUI, or this ChatKit package."
    ) {
        self.service = service
        self.greeting = greeting
        self.conversation = Conversation(
            title: "AI Assistant",
            messages: [
                Message(role: .assistant, text: greeting, streamState: .complete)
            ]
        )
    }

    public func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isStreaming else { return }

        let userMessage = Message(role: .user, text: trimmed, streamState: .complete)
        conversation.messages.append(userMessage)
        inputText = ""

        streamingTask = Task {
            await streamAssistantReply(for: trimmed)
        }
    }

    public func cancelStreaming() {
        streamingTask?.cancel()
        streamingTask = nil

        if let lastIndex = conversation.messages.indices.last,
           conversation.messages[lastIndex].role == .assistant {
            conversation.messages[lastIndex].streamState = .complete
        }
        isStreaming = false
    }

    public func resetConversation() {
        cancelStreaming()
        conversation.messages = [
            Message(role: .assistant, text: greeting, streamState: .complete)
        ]
    }

    private func streamAssistantReply(for prompt: String) async {
        isStreaming = true

        let assistantMessage = Message(role: .assistant, text: "", streamState: .streaming)
        conversation.messages.append(assistantMessage)
        let assistantIndex = conversation.messages.count - 1

        let stream = service.streamResponse(for: prompt)
        for await token in stream {
            guard !Task.isCancelled else { break }
            conversation.messages[assistantIndex].text += token
        }

        if assistantIndex < conversation.messages.count {
            conversation.messages[assistantIndex].streamState = .complete
        }
        isStreaming = false
        streamingTask = nil
    }
}
