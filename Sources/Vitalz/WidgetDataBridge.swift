import Foundation

// MARK: - Widget Data Bridge
//
// Shared between the main Vitalz app and the VitalzWidget extension.
// Uses an App Group container to pass a minimal profile snapshot without a server.

/// A privacy-minimized snapshot containing only the fields the widget needs.
/// Avoids serializing PII like birth city, photos, tracked people, or hobbies
/// into the App Group UserDefaults.
public struct WidgetProfileSnapshot: Codable {
    public let name: String
    public let dateOfBirthTimestamp: Double
    public let primaryHobbyStartDate: Date?
    public let primaryPersonMetDate: Date?
    
    public init(name: String, dateOfBirthTimestamp: Double, primaryHobbyStartDate: Date? = nil, primaryPersonMetDate: Date? = nil) {
        self.name = name
        self.dateOfBirthTimestamp = dateOfBirthTimestamp
        self.primaryHobbyStartDate = primaryHobbyStartDate
        self.primaryPersonMetDate = primaryPersonMetDate
    }
    
    public init(from profile: VitalzProfile) {
        self.name = profile.name
        self.dateOfBirthTimestamp = profile.dateOfBirthTimestamp
        self.primaryHobbyStartDate = profile.hobbies.first(where: { $0.isEnabled })?.startDate
        self.primaryPersonMetDate = profile.trackedPeople.first?.metDate
    }
    
    public var dateOfBirth: Date {
        Date(timeIntervalSince1970: dateOfBirthTimestamp)
    }
}

public struct WidgetDataBridge {
    public static let appGroupID = "group.com.simeon.vitalz"
    public static let profileKey = "widgetProfileData"

    public static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    /// Called by the main app whenever the selected profile changes or is saved.
    /// Only writes the minimal fields the widget needs — no photos, hobbies, or tracked people.
    public static func writeProfile(_ profile: VitalzProfile) {
        guard let defaults = sharedDefaults else { return }
        let snapshot = WidgetProfileSnapshot(from: profile)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: profileKey)
    }

    /// Called by the widget extension to read the current profile snapshot.
    public static func readSnapshot() -> WidgetProfileSnapshot? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(WidgetProfileSnapshot.self, from: data)
    }
}
