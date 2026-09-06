//
//  MessageBubble.swift
//  ChatKit
//
//  Created by twixx  on 04/09/26.
//

import SwiftUI

public struct MessageBubble: View {

    public let message: Message

    @Environment(\.chatConfig) private var config

    public init(message: Message) {
        self.message = message
    }

    private var isUser: Bool { message.role == .user }
    private var isStreaming: Bool { message.streamState == .streaming }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isUser { Spacer(minLength: 48) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: ChatTheme.spacingXS) {
                bubbleContent
                timestamp
            }

            if !isUser { Spacer(minLength: 48) }
        }
        .padding(.horizontal, ChatTheme.spacingLG)
    }

    @ViewBuilder
    private var bubbleContent: some View {
        Text(isStreaming ? message.text + "▌" : message.text)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundStyle(config.textPrimaryColor)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, ChatTheme.spacingMD)
            .padding(.vertical, ChatTheme.spacingMD)
            .background(bubbleBackground)
            .shadow(
                color: isUser ? config.userBubbleEndColor.opacity(0.35) : .clear,
                radius: 8, x: 0, y: 4
            )
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if isUser {
            RoundedRectangle(cornerRadius: ChatTheme.radiusMD)
                .fill(config.userBubbleGradient)
        } else {
            RoundedRectangle(cornerRadius: ChatTheme.radiusMD)
                .fill(config.assistantBubbleColor)
                .overlay(
                    RoundedRectangle(cornerRadius: ChatTheme.radiusMD)
                        .stroke(config.separatorColor, lineWidth: 0.5)
                )
        }
    }

    private var timestamp: some View {
        Text(message.timestamp, format: .dateTime.hour().minute())
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(config.textSecondaryColor)
            .padding(.horizontal, ChatTheme.spacingXS)
    }
}

#Preview {
    VStack(spacing: 12) {
        MessageBubble(message: Message(role: .user, text: "Hey! How does streaming work?"))
        MessageBubble(message: Message(role: .assistant,
                                      text: "Uses AsyncStream<String> under the hood",
                                      streamState: .streaming))
    }
    .padding()
    .background(ChatTheme.backgroundPrimary)
}
