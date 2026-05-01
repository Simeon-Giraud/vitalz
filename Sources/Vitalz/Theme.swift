import SwiftUI

// MARK: - Accent Theme

/// Predefined accent color options the user can choose from.
public enum AccentTheme: String, CaseIterable, Identifiable {
    case electricBlue = "Electric Blue"
    case violet = "Violet"
    case rose = "Rose"
    case emerald = "Emerald"
    case amber = "Amber"
    case coral = "Coral"
    case teal = "Teal"
    case indigo = "Indigo"
    
    public var id: String { rawValue }
    
    public var color: Color {
        switch self {
        case .electricBlue: return Color(hex: "#007AFF")
        case .violet: return Color(hex: "#8B5CF6")
        case .rose: return Color(hex: "#F43F5E")
        case .emerald: return Color(hex: "#10B981")
        case .amber: return Color(hex: "#F59E0B")
        case .coral: return Color(hex: "#FF6B6B")
        case .teal: return Color(hex: "#14B8A6")
        case .indigo: return Color(hex: "#6366F1")
        }
    }
    
    public var uiColor: UIColor {
        UIColor(color)
    }
}

// MARK: - Card Category System

/// Semantic categories for dashboard cards, each with a meaningful color identity.
public enum CardCategory: String {
    case body       // Heartbeats, Breaths, Blinks, Hair, Nails
    case time       // Seconds Alive, Sunsets, Sleep
    case cosmos     // Space Traveler, Full Moons, Jupiter Age
    case mind       // Phone Void, Caffeine, Words Read
    case growth     // Era Share, Mastery
    case bonds      // Shared Days, Shared Heartbeats
    
    /// The dark-mode card background tint for this category.
    public var cardColor: Color {
        Color(UIColor { trait in
            let isDark = trait.userInterfaceStyle == .dark
            switch self {
            case .body:   return isDark ? UIColor(hex: "#1E0A0D") : UIColor(hex: "#FFF1F2")
            case .time:   return isDark ? UIColor(hex: "#1A1408") : UIColor(hex: "#FFFBEB")
            case .cosmos: return isDark ? UIColor(hex: "#0E0818") : UIColor(hex: "#F5F3FF")
            case .mind:   return isDark ? UIColor(hex: "#081018") : UIColor(hex: "#EFF6FF")
            case .growth: return isDark ? UIColor(hex: "#071410") : UIColor(hex: "#ECFDF5")
            case .bonds:  return isDark ? UIColor(hex: "#061214") : UIColor(hex: "#F0FDFA")
            }
        })
    }
    
    /// The accent/value highlight color for this category.
    public var accentColor: Color {
        switch self {
        case .body:   return Color(hex: "#FF6B6B")
        case .time:   return Color(hex: "#FBBF24")
        case .cosmos: return Color(hex: "#A78BFA")
        case .mind:   return Color(hex: "#60A5FA")
        case .growth: return Color(hex: "#34D399")
        case .bonds:  return Color(hex: "#2DD4BF")
        }
    }
    
    /// The text color used for the big value numbers in this category.
    public var valueColor: Color {
        switch self {
        case .body:   return Color(hex: "#FCA5A5")
        case .time:   return Color(hex: "#FDE68A")
        case .cosmos: return Color(hex: "#C4B5FD")
        case .mind:   return Color(hex: "#93C5FD")
        case .growth: return Color(hex: "#6EE7B7")
        case .bonds:  return Color(hex: "#5EEAD4")
        }
    }
    
    /// SF Symbol representing this category.
    public var icon: String {
        switch self {
        case .body:   return "heart.fill"
        case .time:   return "clock.fill"
        case .cosmos: return "sparkles"
        case .mind:   return "brain.head.profile"
        case .growth: return "flame.fill"
        case .bonds:  return "person.2.fill"
        }
    }
    
    /// Human-readable label.
    public var label: String {
        switch self {
        case .body:   return "Body"
        case .time:   return "Time"
        case .cosmos: return "Cosmos"
        case .mind:   return "Mind"
        case .growth: return "Growth"
        case .bonds:  return "Bonds"
        }
    }
}

// MARK: - Card Category Mapping

public extension CardData.ID {
    /// Maps each card to its semantic category.
    var category: CardCategory {
        switch self {
        case .heartbeats, .breathsTaken, .timesBlinked, .hairGrowth, .nailGrowth:
            return .body
        case .secondsAlive, .sunsets, .sleep:
            return .time
        case .spaceTraveler, .fullMoons, .jupiterAge:
            return .cosmos
        case .phoneVoid, .caffeineRiver, .wordsRead:
            return .mind
        case .passionEra, .masteryHours:
            return .growth
        case .sharedDays, .sharedHeartbeats:
            return .bonds
        }
    }
}

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

    /// Adaptive secondary text color for labels and supporting copy.
    static let vitalzSecondaryText = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#8E8E93") : UIColor(hex: "#6E6E73")
    })
    
    /// The user's chosen accent color — reads dynamically from UserDefaults.
    static var vitalzAccent: Color {
        let stored = UserDefaults.standard.string(forKey: "accentTheme") ?? AccentTheme.electricBlue.rawValue
        return (AccentTheme(rawValue: stored) ?? .electricBlue).color
    }
    
    /// Legacy alias — kept for backward compatibility, now routes through accent.
    static var vitalzBlue: Color { vitalzAccent }
    
    /// Apple Health style gradient for dynamic data visualization.
    static var vitalzGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [vitalzAccent.opacity(0.7), vitalzAccent]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Adaptive card color: Dark Grey in dark mode, Pure White in light mode.
    static let vitalzCard = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#1A1A1A") : .white
    })

    /// Adaptive elevated control color for buttons, segmented choices, and inset groups.
    static let vitalzControl = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#242426") : UIColor(hex: "#F0F1F3")
    })

    /// Adaptive divider color.
    static let vitalzDivider = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.1) : UIColor.black.withAlphaComponent(0.08)
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
            // Using a serif design for an elegant appearance
            .font(.system(size: 56, weight: .bold, design: .default))
            // Applying the user's accent color
            .foregroundColor(.vitalzAccent)
            // Adding a subtle glow/shadow
            .shadow(color: Color.vitalzAccent.opacity(0.35), radius: 8, x: 0, y: 4)
            // Slight letter spacing
            .kerning(1.5)
    }
}

public extension View {
    /// Applies the luxury watch `HeroStats` aesthetic, to be used on primary number displays.
    func heroStatsStyle() -> some View {
        self.modifier(HeroStatsModifier())
    }
}
