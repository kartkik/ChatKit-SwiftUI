//
//  TypingIndicator.swift
//  ChatKit
//
//  Created by twixx  on 04/09/26.
//

import SwiftUI

public struct TypingIndicator: View {

    @Environment(\.chatConfig) private var config
    @State private var phase: Int = 0

    private let dotCount = 3
    private let dotSize: CGFloat = 8
    private let dotSpacing: CGFloat = 5

    public init() {}

    public var body: some View {
        HStack(alignment: .center, spacing: dotSpacing) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(config.textSecondaryColor)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(phase == index ? 1.4 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.38)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.18),
                        value: phase
                    )
            }
        }
        .padding(.horizontal, ChatTheme.spacingMD)
        .padding(.vertical, ChatTheme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: ChatTheme.radiusMD)
                .fill(config.assistantBubbleColor)
        )
        .onAppear {
            withAnimation { phase = 0 }
        }
    }
}

#Preview {
    TypingIndicator()
        .padding()
        .background(ChatTheme.backgroundPrimary)
}
