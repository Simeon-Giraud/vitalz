import SwiftUI

// MARK: - Color Palette

public extension Color {
    /// Pure Black (#000000) for the main background.
    static let vitalzBackground = Color(hex: "#000000")
    
    /// White for the primary text.
    static let vitalzText = Color.white
    
    /// Warm Gold (#C9A84C) for key numbers and accents.
    static let vitalzGold = Color(hex: "#C9A84C")
    
    /// Dark Grey (#1A1A1A) for cards and secondary elevated surfaces.
    static let vitalzCard = Color(hex: "#1A1A1A")
    
    /// Internal helper allowing for easy Hex-based Color initialization.
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
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}

// MARK: - Typography & View Modifiers

/// A view modifier to apply a premium, luxury watch aesthetic to key numerical statistics.
public struct HeroStatsModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            // Using a serif design for an elegant, engraved watch-dial appearance
            .font(.system(size: 56, weight: .bold, design: .serif))
            // Applying the Warm Gold accent color
            .foregroundColor(.vitalzGold)
            // Adding a subtle glow/shadow to emulate the reflection on polished metal
            .shadow(color: Color.vitalzGold.opacity(0.35), radius: 8, x: 0, y: 4)
            // Slight letter spacing for a deliberate, premium layout
            .kerning(1.5)
    }
}

public extension View {
    /// Applies the luxury watch `HeroStats` aesthetic, to be used on primary number displays.
    func heroStatsStyle() -> some View {
        self.modifier(HeroStatsModifier())
    }
}
