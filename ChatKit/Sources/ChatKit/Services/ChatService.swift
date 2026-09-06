//
//  ChatService.swift
//  ChatKit
//
//  Created by twixx  on 04/09/26.
//

import Foundation

// MARK: - Protocol

/// Defines the streaming interface that ChatViewModel depends on.
/// Conformers must be Sendable because they are used across actor boundaries.
public protocol ChatServiceProtocol: Sendable {
    /// Returns an `AsyncStream` that yields string tokens one by one,
    /// simulating a streaming language-model response.
    /// - Parameter prompt: The user's most recent message text.
    /// - Returns: An `AsyncStream<String>` of incremental tokens.
    func streamResponse(for prompt: String) -> AsyncStream<String>
}

// MARK: - Mock Implementation

public final class MockChatService: ChatServiceProtocol {

    private let minDelay: Double
    private let maxDelay: Double

    public init(minDelay: Double = 0.03, maxDelay: Double = 0.08) {
        self.minDelay = minDelay
        self.maxDelay = maxDelay
    }

    private static let responses: [(keywords: [String], reply: String)] = [
        (
            ["hello", "hi", "hey", "greetings"],
            "Hey there! 👋 Great to meet you. I'm your AI assistant inside ChatKit — a SwiftUI package built with MVVM and async/await streaming. What can I help you with today?"
        ),
        (
            ["swift", "swiftui", "code", "package", "spm"],
            "ChatKit is built as a local Swift Package using Swift 5.9 and SwiftUI. The MVVM layer lives entirely inside the package — `ChatViewModel` is `@Observable`, and responses stream in via `AsyncStream<String>`. The host app only needs to present `ChatScreen()`. Clean separation of concerns!"
        ),
        (
            ["stream", "streaming", "async", "await"],
            "Streaming is powered by Swift Concurrency — specifically `AsyncStream<String>`. The `MockChatService` yields tokens every 30–80ms to simulate a real LLM. The `ChatViewModel` iterates over the stream with `for await token in stream { }`, appending each token to the live message and letting SwiftUI reactively update the bubble in real time."
        ),
        (
            ["mvvm", "architecture", "pattern", "design"],
            "The architecture follows strict MVVM: \n\n• **Model** — `Message` and `Conversation` are plain Swift structs, fully `Sendable`.\n• **ViewModel** — `ChatViewModel` is `@MainActor @Observable`, owning all mutable state.\n• **View** — SwiftUI views observe the VM via `@State` / `@Bindable` with zero business logic.\n\nThe service protocol (`ChatServiceProtocol`) further decouples the VM from any concrete implementation."
        ),
        (
            ["joke", "funny", "laugh", "humor"],
            "Why do Swift developers prefer dark mode? 🤔\n\nBecause light attracts bugs! 🐛\n\n(Okay okay, I'll stick to code questions from here on 😄)"
        ),
        (
            ["bye", "goodbye", "see you", "later"],
            "Goodbye! It was great chatting with you. Feel free to come back any time. Happy coding! 👨‍💻✨"
        ),
    ]

    private static let fallbackReplies: [String] = [
        "That's an interesting question! As a local mock, I don't have access to real-time information, but I'd be happy to discuss Swift, SwiftUI architecture, or this ChatKit package in more detail.",
        "Great question! In a production version of this app, a real LLM would give you a thorough answer via the same `ChatServiceProtocol`. For now, I'm your friendly offline mock — try asking me about Swift, MVVM, or streaming! 🚀",
        "Interesting topic! This ChatKit package demonstrates clean MVVM with async/await streaming in SwiftUI. The separation between the Swift Package and the host app means you can reuse this chat UI in any iOS project.",
    ]

    public func streamResponse(for prompt: String) -> AsyncStream<String> {
        let reply = Self.reply(for: prompt)
        let minDelay = self.minDelay
        let maxDelay = self.maxDelay

        return AsyncStream<String> { continuation in
            Task {
                let tokens = Self.tokenise(reply)
                for token in tokens {
                    // Randomised delay per token to feel organic
                    let delay = Double.random(in: minDelay...maxDelay)
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    // Check cancellation so the stream can be torn down cleanly
                    if Task.isCancelled { break }
                    continuation.yield(token)
                }
                continuation.finish()
            }
        }
    }

    // MARK: - Helpers

    /// Splits reply text into small chunks (words + trailing spaces).
    private static func tokenise(_ text: String) -> [String] {
        var tokens: [String] = []
        var buffer = ""
        for char in text {
            buffer.append(char)
            // Emit on word boundaries (space, newline) or at punctuation clusters
            if char == " " || char == "\n" {
                tokens.append(buffer)
                buffer = ""
            }
        }
        if !buffer.isEmpty { tokens.append(buffer) }
        return tokens
    }

    /// Picks the best canned reply for the given prompt using keyword matching.
    private static func reply(for prompt: String) -> String {
        let lower = prompt.lowercased()
        for entry in responses {
            if entry.keywords.contains(where: { lower.contains($0) }) {
                return entry.reply
            }
        }
        return fallbackReplies.randomElement() ?? fallbackReplies[0]
    }
}
