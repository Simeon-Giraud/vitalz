import UIKit

// MARK: - Haptic Engine
//
// A centralized, stateless haptic manager modeled after the precise
// feedback of a high-end mechanical watch. Each method maps to a
// distinct tactile moment in the app's interaction language.
//
// All generators are lazily prepared and fire-and-forget.
// If the device has haptics disabled at the system level,
// UIFeedbackGenerator silently no-ops — no guards needed.

public enum HapticEngine {

    // MARK: - Tick

    /// A very light, crisp tap — the second hand of a mechanical watch.
    /// Use for: expanding a card, scrolling to a milestone, minor selections.
    public static func playTick() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: 0.6)
    }

    // MARK: - Mechanical Click

    /// A firm, satisfying thud — flipping a heavy physical switch.
    /// Use for: toggling privacy switches, pressing primary action buttons.
    public static func playMechanicalClick() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred(intensity: 0.8)
    }

    // MARK: - Success

    /// A subtle success vibration — the satisfying "click" of a crown locking into place.
    /// Use for: successful QR decode, profile added to Orbit.
    public static func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}
