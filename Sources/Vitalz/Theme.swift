import SwiftUI

// MARK: - Color Palette

public extension Color {
    /// Adaptive background color: Pure Black in dark mode, Off-White in light mode.
    static let vitalzBackground = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#000000") : UIColor(hex: "#FAFAFA")
    })
    
    /// Adaptive text color: White in dark mode, Dark Charcoal in light mode.
    static let vitalzText = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .white : UIColor(hex: "#1A1A1A")
    })
    
    /// Warm Gold (#C9A84C) for key numbers and accents. Remains constant for brand identity.
    static let vitalzGold = Color(hex: "#C9A84C")
    
    /// Adaptive card color: Dark Grey in dark mode, Pure White in light mode.
    static let vitalzCard = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#1A1A1A") : .white
    })
    
    /// Adaptive shadow color for depth.
    static let vitalzShadow = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.black.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.1)
    })
    
    /// Internal helper allowing for easy Hex-based Color initialization.
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}

public extension UIColor {
    convenience init(hex: String) {
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
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
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
