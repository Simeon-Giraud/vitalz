import SwiftUI

// MARK: - Wallpaper Theme Model
//
// A procedural background system using pure SwiftUI to create subtle,
// organic gradients inspired by Apple Health and Home apps.

public enum WallpaperTheme: String, CaseIterable, Identifiable {
    case standardLight
    case standardDark
    case healthMutedDawn
    case homeDeepHorizon

    public var id: String { rawValue }

    public var displayName: LocalizedStringResource {
        switch self {
        case .standardLight: return "Light"
        case .standardDark: return "Dark"
        case .healthMutedDawn: return "Dawn"
        case .homeDeepHorizon: return "Horizon"
        }
    }

    /// The procedural background view (Color or Gradient).
    @ViewBuilder
    public var backgroundView: some View {
        switch self {
        case .standardLight:
            Color.white
        case .standardDark:
            Color.black
        case .healthMutedDawn:
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.94, blue: 0.92), // Cream
                    Color(red: 0.96, green: 0.86, blue: 0.86)  // Muted Coral
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .homeDeepHorizon:
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.22), // Dark Slate
                    Color(red: 0.05, green: 0.08, blue: 0.12)  // Deep Navy
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    /// The text color that ensures perfect legibility over the chosen background.
    public var textColor: Color {
        switch self {
        case .standardLight, .healthMutedDawn:
            return Color(white: 0.1) // Dark grey for light backgrounds
        case .standardDark, .homeDeepHorizon:
            return .white // White for dark backgrounds
        }
    }
}
