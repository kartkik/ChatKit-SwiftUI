//
//  ChatConfig.swift
//  ChatKit
//
//  Created by twixx  on 04/09/26.
//

import SwiftUI

public struct ChatConfig: Sendable {

    public var navigationTitle: String
    public var showResetButton: Bool
    public var greetingMessage: String
    public var inputPlaceholder: String
    public var backgroundColor: Color
    public var userBubbleStartColor: Color
    public var userBubbleEndColor: Color
    public var assistantBubbleColor: Color
    public var accentColor: Color
    public var textPrimaryColor: Color
    public var textSecondaryColor: Color
    public var inputBarBackground: Color
    public var separatorColor: Color

    public var userBubbleGradient: LinearGradient {
        LinearGradient(
            colors: [userBubbleStartColor, userBubbleEndColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public static let `default` = ChatConfig()

    public init(
        navigationTitle: String      = "AI Assistant",
        showResetButton: Bool        = true,
        greetingMessage: String      = "Hello! 👋 I'm your AI assistant. Ask me anything about Swift, SwiftUI, or this ChatKit package.",
        inputPlaceholder: String     = "Message…",
        backgroundColor: Color      = Color(hex: "#0F0F13"),
        userBubbleStartColor: Color = Color(hex: "#9B8FFF"),
        userBubbleEndColor: Color   = Color(hex: "#6C63FF"),
        assistantBubbleColor: Color = Color(hex: "#242432"),
        accentColor: Color          = Color(hex: "#8B5CF6"),
        textPrimaryColor: Color     = Color(hex: "#F5F5FA"),
        textSecondaryColor: Color   = Color(hex: "#9494A8"),
        inputBarBackground: Color   = Color(hex: "#17171F"),
        separatorColor: Color       = Color(hex: "#2A2A38")
    ) {
        self.navigationTitle      = navigationTitle
        self.showResetButton      = showResetButton
        self.greetingMessage      = greetingMessage
        self.inputPlaceholder     = inputPlaceholder
        self.backgroundColor      = backgroundColor
        self.userBubbleStartColor = userBubbleStartColor
        self.userBubbleEndColor   = userBubbleEndColor
        self.assistantBubbleColor = assistantBubbleColor
        self.accentColor          = accentColor
        self.textPrimaryColor     = textPrimaryColor
        self.textSecondaryColor   = textSecondaryColor
        self.inputBarBackground   = inputBarBackground
        self.separatorColor       = separatorColor
    }
}

struct ChatConfigKey: EnvironmentKey {
    static let defaultValue: ChatConfig = .default
}

extension EnvironmentValues {
    var chatConfig: ChatConfig {
        get { self[ChatConfigKey.self] }
        set { self[ChatConfigKey.self] = newValue }
    }
}
