//
//  AppChatService.swift
//  ChatApp-SwiftUI
//
//  Created by twixx  on 04/09/26.
//

import Foundation
import ChatKit

final class AppChatService: ChatServiceProtocol {

    private let minTokenDelay: Double = 0.03
    private let maxTokenDelay: Double = 0.07

    private static let responses: [(keywords: [String], reply: String)] = [
        (
            keywords: ["hello", "hi", "hey", "greetings", "howdy"],
            reply: """
            Hey there! 👋 Welcome to the ChatApp demo.

            I'm an AI assistant powered by the **ChatKit** Swift Package. \
            The app you're running is the *host app* — it owns all my responses \
            and injects them into ChatKit via `AppChatService`. \
            ChatKit itself is just the UI shell.

            What would you like to talk about?
            """
        ),
        (
            keywords: ["chatkit", "package", "spm", "swift package", "architecture"],
            reply: """
            Great question! Here's how the architecture works:

            📦 **ChatKit (Swift Package)**
            • Views, ViewModel, Models, Protocol — pure UI shell
            • Defines `ChatServiceProtocol` but ships no hardcoded data

            📱 **Host App**
            • Owns `AppChatService` — ALL responses live here
            • Injects the service via `ChatScreen(service: AppChatService())`
            • Owns `ChatScreenViewModel` with MVVM config

            This means you can change every response without touching the package. ✅
            """
        ),
        (
            keywords: ["stream", "streaming", "async", "await", "asyncstream"],
            reply: """
            Streaming is powered by **Swift Concurrency**:

            1. `AppChatService.streamResponse(for:)` returns an `AsyncStream<String>`
            2. Tokens are yielded every 30–70 ms (configurable in `AppChatService`)
            3. `ChatViewModel` iterates with `for await token in stream { }`
            4. Each token is appended to the live message — SwiftUI re-renders the bubble in real time
            5. A blinking cursor `▌` shows while `streamState == .streaming`
            """
        ),
        (
            keywords: ["mvvm", "viewmodel", "view model", "pattern"],
            reply: """
            The project uses strict **MVVM** across both the package and the host app:

            **ChatKit package**
            • Model → `Message`, `Conversation` (value types, Sendable)
            • ViewModel → `ChatViewModel` (@MainActor, @Observable)
            • View → `ChatScreen`, `MessageBubble`, `MessageInputBar`, `TypingIndicator`
            • Service → `ChatServiceProtocol` (protocol, no concrete data)

            **Host App**
            • `ChatScreenViewModel` — owns config + service injection
            • `AppChatService` — all response data owned here
            • `ChatApp_SwiftUIApp` — thin router (Splash → Chat)

            Views own **zero** business logic. 💯
            """
        ),
        (
            keywords: ["swiftui", "swift", "ios", "apple", "xcode"],
            reply: """
            This app targets **iOS 17+** and uses the latest SwiftUI APIs:

            • `@Observable` macro instead of `ObservableObject` + `@Published`
            • `@Bindable` for two-way VM bindings in the input bar
            • `AsyncStream<String>` for streaming (no Combine needed)
            • `LazyVStack` for efficient message list rendering
            • `.scrollDismissesKeyboard(.interactively)` for smooth UX
            • `contentTransition(.symbolEffect(.replace))` on the send/stop button
            """
        ),
        (
            keywords: ["joke", "funny", "laugh", "humor", "fun"],
            reply: """
            Why did the Swift developer go broke? 😄

            Because he used too many **optional** spending habits — \
            and kept force-unwrapping his wallet! 💸

            `let money: Double? = wallet.balance // nil 😅`
            """
        ),
        (
            keywords: ["bye", "goodbye", "see you", "later", "ciao", "quit"],
            reply: "Goodbye! Happy coding. Remember — all my responses are in `AppChatService.swift` in the host app, so feel free to customise them! 👋✨"
        ),
    ]

    private static let fallbackReplies: [String] = [
        "Interesting! I'm a host-app-controlled assistant. Edit `AppChatService.swift` to add a response for that topic. 📝",
        "I don't have a specific answer for that yet — but you can add one in `AppChatService.responses` in the host app without touching ChatKit at all!",
        "Good question! My responses live in `AppChatService` inside the host app. Add a new keyword entry there to make me smarter. 🧠",
    ]

    func streamResponse(for prompt: String) -> AsyncStream<String> {
        let reply = Self.bestReply(for: prompt)
        let min = minTokenDelay
        let max = maxTokenDelay

        return AsyncStream<String> { continuation in
            Task {
                for token in Self.tokenise(reply) {
                    let delay = Double.random(in: min...max)
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    guard !Task.isCancelled else { break }
                    continuation.yield(token)
                }
                continuation.finish()
            }
        }
    }

    private static func bestReply(for prompt: String) -> String {
        let lower = prompt.lowercased()
        for entry in responses {
            if entry.keywords.contains(where: { lower.contains($0) }) {
                return entry.reply
            }
        }
        return fallbackReplies.randomElement() ?? fallbackReplies[0]
    }

    private static func tokenise(_ text: String) -> [String] {
        var tokens: [String] = []
        var buffer = ""
        for char in text {
            buffer.append(char)
            if char == " " || char == "\n" {
                tokens.append(buffer)
                buffer = ""
            }
        }
        if !buffer.isEmpty { tokens.append(buffer) }
        return tokens
    }
}
