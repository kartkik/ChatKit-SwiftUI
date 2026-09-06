//
//  ChatTheme.swift
//  ChatKit
//
//  Created by twixx  on 04/09/26.
//

import SwiftUI

public enum ChatTheme {

    public static let backgroundPrimary = Color(hex: "#0F0F13")
    public static let surface = Color(hex: "#1C1C24")
    public static let userBubble = Color(hex: "#6C63FF")
    public static let userBubbleHighlight = Color(hex: "#9B8FFF")
    public static let assistantBubble = Color(hex: "#242432")
    public static let accent = Color(hex: "#8B5CF6")
    public static let accentSecondary = Color(hex: "#6C63FF")
    public static let textPrimary = Color(hex: "#F5F5FA")
    public static let textSecondary = Color(hex: "#9494A8")
    public static let separator = Color(hex: "#2A2A38")
    public static let inputBackground = Color(hex: "#17171F")

    public static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [userBubbleHighlight, userBubble, accentSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public static let spacingXS: CGFloat = 4
    public static let spacingSM: CGFloat = 8
    public static let spacingMD: CGFloat = 12
    public static let spacingLG: CGFloat = 16
    public static let spacingXL: CGFloat = 24

    public static let radiusMD: CGFloat = 16
    public static let radiusLG: CGFloat = 20
    public static let radiusXL: CGFloat = 26

    public static let maxBubbleWidthRatio: CGFloat = 0.72

    public static let springResponse: Double = 0.45
    public static let springDamping: Double = 0.72
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
