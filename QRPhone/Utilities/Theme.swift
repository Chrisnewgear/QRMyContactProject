//
//  Theme.swift
//  QRPhone
//
//  Created by GitHub Copilot on 22/2/26.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // New Color Palette
    // Deep Blue: #3A75FF
    // Cyan/Teal: #48C6EF
    // Lime Green: #6AC64F
    // Light Blue: #5BC0EB
    // Teal Green: #4BB498
    
    static let qrDeepBlue = Color(hex: "3A75FF")
    static let qrCyan = Color(hex: "48C6EF")
    static let qrLimeGreen = Color(hex: "6AC64F")
    static let qrLightBlue = Color(hex: "5BC0EB")
    static let qrTealGreen = Color(hex: "4BB498")

    static let qrPrimary = qrDeepBlue
    static let qrSecondary = qrCyan
    static let qrBackground = Color(UIColor.systemGroupedBackground)
    static let qrCard = Color(UIColor.secondarySystemGroupedBackground)
    
    // Gradient colors
    static let qrGradientStart = qrDeepBlue
    static let qrGradientEnd = qrLimeGreen
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.qrCard)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PrimaryButtonContent(configuration: configuration)
    }

    struct PrimaryButtonContent: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .foregroundColor(isEnabled ? .qrPrimary : Color.gray)
                .cornerRadius(12)
                .opacity(isEnabled ? 1.0 : 0.6)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.spring(), value: configuration.isPressed)
        }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.qrCard)
            .foregroundColor(.qrPrimary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.qrPrimary, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }
}
