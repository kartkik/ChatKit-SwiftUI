//
//  ChatScreen.swift
//  ChatKit
//
//  Created by twixx  on 04/09/26.
//

import SwiftUI

@MainActor
public struct ChatScreen: View {

    @State private var viewModel: ChatViewModel
    private let config: ChatConfig

    public init(
        service: ChatServiceProtocol = MockChatService(),
        config: ChatConfig = .default
    ) {
        self.config = config
        _viewModel = State(
            wrappedValue: ChatViewModel(
                service: service,
                greeting: config.greetingMessage
            )
        )
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                config.backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    messageList
                    MessageInputBar(viewModel: viewModel)
                }
            }
            .navigationTitle(config.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(config.backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { toolbarContent }
        }
        .environment(\.chatConfig, config)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: ChatTheme.spacingMD) {
                    ForEach(viewModel.conversation.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: message.role == .user ? .trailing : .leading)
                                        .combined(with: .opacity),
                                    removal: .opacity
                                )
                            )
                    }

                    if viewModel.isStreaming &&
                        (viewModel.conversation.messages.last?.streamState == .complete ||
                         viewModel.conversation.messages.last?.role == .user) {
                        HStack {
                            TypingIndicator()
                                .padding(.leading, ChatTheme.spacingLG)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            Spacer()
                        }
                        .id("typing-indicator")
                    }

                    Color.clear.frame(height: 8).id("bottom-anchor")
                }
                .padding(.top, ChatTheme.spacingMD)
                .padding(.bottom, ChatTheme.spacingSM)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.conversation.messages.count) { scrollToBottom(proxy: proxy) }
            .onChange(of: viewModel.conversation.messages.last?.text) { scrollToBottom(proxy: proxy) }
            .onChange(of: viewModel.isStreaming) { scrollToBottom(proxy: proxy) }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: ChatTheme.spacingSM) {
                Circle()
                    .fill(viewModel.isStreaming ? Color(hex: "#22C55E") : config.textSecondaryColor)
                    .frame(width: 7, height: 7)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isStreaming)

                Text(config.navigationTitle)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(config.textPrimaryColor)
            }
        }

        if config.showResetButton {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        viewModel.resetConversation()
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(config.textSecondaryColor)
                }
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            proxy.scrollTo("bottom-anchor", anchor: .bottom)
        }
    }
}

#Preview {
    ChatScreen()
        .preferredColorScheme(.dark)
}
