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
        Hey! 👋

        Nice to meet you. How can I help you today?
        """
    ),
    
    (
        keywords: ["how are you", "how are you doing", "how do you do", "you okay"],
        reply: """
        I'm doing great, thanks for asking! 😊

        How are you doing today?
        """
    ),
    
    (
        keywords: ["help", "can you help me", "i need help", "assist me"],
        reply: """
        Of course! 😊 I'm here to help.

        You can ask me questions, have a conversation, or ask for help with Swift, iOS, programming, and more.

        What would you like help with?
        """
    ),
    
    (
        keywords: ["what can you do", "what do you do", "your capabilities"],
        reply: """
        I can help with lots of things! 😊

        • Answer questions
        • Help with Swift and iOS development
        • Explain programming concepts
        • Tell jokes
        • Have a friendly conversation

        Just ask me anything! 🚀
        """
    ),
    
    (
        keywords: ["who are you", "what are you"],
        reply: """
        I'm a friendly AI assistant built into this ChatApp demo. 🤖

        I'm here to chat with you and help answer your questions!
        """
    ),
    
    (
        keywords: ["thank you", "thanks", "thank", "thx"],
        reply: """
        You're very welcome! 😊

        I'm always happy to help. Let me know if you need anything else!
        """
    ),
    
    (
        keywords: ["good morning"],
        reply: """
        Good morning! ☀️

        I hope you have a wonderful day ahead. What can I help you with?
        """
    ),
    
    (
        keywords: ["good afternoon"],
        reply: """
        Good afternoon! 😊

        Hope your day is going well! How can I help?
        """
    ),
    
    (
        keywords: ["good evening"],
        reply: """
        Good evening! 🌙

        How has your day been? Is there anything I can help you with?
        """
    ),
    
    (
        keywords: ["joke", "funny", "laugh", "humor"],
        reply: """
        Here's one for you! 😄

        Why do programmers prefer dark mode?

        Because light attracts bugs! 🐛😂
        """
    ),
    
    (
        keywords: ["chatkit", "package", "spm", "swift package"],
        reply: """
        ChatKit is the Swift Package responsible for the chat interface.

        The host app provides the data and responses, while ChatKit handles displaying the conversation. 📦
        """
    ),
    
    (
        keywords: ["swift", "swiftui", "ios", "xcode"],
        reply: """
        Swift and SwiftUI are great technologies for building modern Apple applications! 🍎

        Feel free to ask me anything about iOS development.
        """
    ),
    
    (
        keywords: ["bye", "goodbye", "see you", "later", "ciao", "quit"],
        reply: """
        Goodbye! 👋😊

        It was nice talking with you. Have a great day!
        """
    )
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
