import Foundation

// MARK: - Widget Data Bridge
//
// Shared between the main Vitalz app and the VitalzWidget extension.
// Uses an App Group container to pass profile data without a server.

public struct WidgetDataBridge {
    public static let appGroupID = "group.com.simeon.vitalz"
    public static let profileKey = "widgetProfileData"

    public static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    /// Called by the main app whenever the selected profile changes or is saved.
    public static func writeProfile(_ profile: VitalzProfile) {
        guard let defaults = sharedDefaults,
              let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: profileKey)
    }

    /// Called by the widget extension to read the current profile snapshot.
    public static func readProfile() -> VitalzProfile? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(VitalzProfile.self, from: data)
    }
}
