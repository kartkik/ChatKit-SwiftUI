//
//  MessageInputBar.swift
//  ChatKit
//
//  Created by twixx  on 04/09/26.
//

import SwiftUI

public struct MessageInputBar: View {

    @Bindable var viewModel: ChatViewModel
    @Environment(\.chatConfig) private var config
    @FocusState private var isFocused: Bool
    @State private var sendTrigger = false

    public init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            Divider().background(config.separatorColor)

            HStack(alignment: .bottom, spacing: ChatTheme.spacingMD) {
                textField
                actionButton
            }
            .padding(.horizontal, ChatTheme.spacingLG)
            .padding(.vertical, ChatTheme.spacingMD)
            .background(
                config.backgroundColor.ignoresSafeArea(edges: .bottom)
            )
        }
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.7), trigger: sendTrigger)
    }

    private var textField: some View {
        TextField(config.inputPlaceholder, text: $viewModel.inputText, axis: .vertical)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundStyle(config.textPrimaryColor)
            .tint(config.accentColor)
            .lineLimit(1...5)
            .padding(.horizontal, ChatTheme.spacingMD)
            .padding(.vertical, ChatTheme.spacingSM + 2)
            .background(
                RoundedRectangle(cornerRadius: ChatTheme.radiusXL)
                    .fill(config.inputBarBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: ChatTheme.radiusXL)
                            .stroke(
                                isFocused ? config.accentColor.opacity(0.6) : config.separatorColor,
                                lineWidth: isFocused ? 1.5 : 0.5
                            )
                    )
            )
            .focused($isFocused)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .onSubmit {
                if viewModel.canSend { send() }
            }
            .disabled(viewModel.isStreaming)
            .accessibilityLabel("Message input field")
            .accessibilityHint("Double tap to compose a message")
    }

    private var actionButton: some View {
        Button(action: {
            viewModel.isStreaming ? viewModel.cancelStreaming() : send()
        }) {
            ZStack {
                Circle()
                    .fill(buttonFill)
                    .frame(width: 44, height: 44)
                    .shadow(color: config.accentColor.opacity(0.4), radius: 6, x: 0, y: 3)

                Image(systemName: viewModel.isStreaming ? "stop.fill" : "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .disabled(!viewModel.canSend && !viewModel.isStreaming)
        .scaleEffect(viewModel.canSend || viewModel.isStreaming ? 1.0 : 0.85)
        .animation(
            .spring(response: ChatTheme.springResponse, dampingFraction: ChatTheme.springDamping),
            value: viewModel.canSend
        )
        .accessibilityLabel(viewModel.isStreaming ? "Stop generating" : "Send message")
        .accessibilityHint(viewModel.isStreaming ? "Stops the current response" : "Sends your message to the assistant")
    }

    private var buttonFill: AnyShapeStyle {
        if viewModel.isStreaming {
            return AnyShapeStyle(Color(hex: "#EF4444"))
        } else if viewModel.canSend {
            return AnyShapeStyle(config.userBubbleGradient)
        } else {
            return AnyShapeStyle(config.separatorColor)
        }
    }

    private func send() {
        sendTrigger.toggle()
        isFocused = false
        viewModel.sendMessage()
    }
}
