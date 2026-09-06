//
//  ChatScreenViewModel.swift
//  ChatApp-SwiftUI
//
//  Created by twixx  on 04/09/26.
//

import SwiftUI
import ChatKit

@MainActor
@Observable
final class ChatScreenViewModel {

    let service: any ChatServiceProtocol = AppChatService()

    var config: ChatConfig = ChatConfig(
        navigationTitle:      "AI Chat",
        showResetButton:      true,
        greetingMessage:      "Hey! 👋 I'm your AI assistant — built with ChatKit.\nAsk me about Swift, SwiftUI, streaming, or MVVM architecture!",
        inputPlaceholder:     "Type a message…",
        backgroundColor:      Color(hex: "#0F0F13"),
        userBubbleStartColor: Color(hex: "#9B8FFF"),
        userBubbleEndColor:   Color(hex: "#6C63FF"),
        assistantBubbleColor: Color(hex: "#1E1E2C"),
        accentColor:          Color(hex: "#8B5CF6"),
        textPrimaryColor:     Color(hex: "#F5F5FA"),
        textSecondaryColor:   Color(hex: "#9494A8"),
        inputBarBackground:   Color(hex: "#17171F"),
        separatorColor:       Color(hex: "#2A2A38")
    )
}
