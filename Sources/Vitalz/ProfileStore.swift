import Combine
import Foundation

public struct VitalzProfile: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var dateOfBirthTimestamp: Double
    public var imageData: Data?

    public init(
        id: String = UUID().uuidString,
        name: String,
        dateOfBirthTimestamp: Double,
        imageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.dateOfBirthTimestamp = dateOfBirthTimestamp
        self.imageData = imageData
    }

    public var dateOfBirth: Date {
        Date(timeIntervalSince1970: dateOfBirthTimestamp)
    }
}

public final class ProfileStore: ObservableObject {
    @Published public private(set) var profiles: [VitalzProfile] {
        didSet { save() }
    }

    @Published public private(set) var selectedProfileID: String {
        didSet {
            saveSelectedProfileID()
            saveLegacySelectedProfile()
        }
    }

    private let defaults: UserDefaults
    private let profilesKey = "vitalzProfiles"
    private let selectedProfileIDKey = "selectedProfileID"
    private let legacyNameKey = "userName"
    private let legacyDOBKey = "userDOBTimestamp"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let loadedProfiles = Self.loadProfiles(from: defaults, key: profilesKey)
        if loadedProfiles.isEmpty {
            let legacyTimestamp = defaults.double(forKey: legacyDOBKey)
            let fallbackDate = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
            let timestamp = legacyTimestamp > 0 ? legacyTimestamp : fallbackDate.timeIntervalSince1970
            let name = defaults.string(forKey: legacyNameKey).flatMap { $0.isEmpty ? nil : $0 } ?? "Me"
            let profile = VitalzProfile(name: name, dateOfBirthTimestamp: timestamp)
            self.profiles = [profile]
            self.selectedProfileID = profile.id
        } else {
            self.profiles = loadedProfiles
            let savedID = defaults.string(forKey: selectedProfileIDKey)
            self.selectedProfileID = loadedProfiles.first(where: { $0.id == savedID })?.id ?? loadedProfiles[0].id
        }

        save()
        saveSelectedProfileID()
    }

    public var selectedProfile: VitalzProfile {
        profiles.first { $0.id == selectedProfileID } ?? profiles[0]
    }

    public func selectProfile(id: String) {
        guard profiles.contains(where: { $0.id == id }) else { return }
        selectedProfileID = id
    }

    @discardableResult
    public func addProfile(name: String = "Friend", dateOfBirth: Date, imageData: Data? = nil) -> VitalzProfile {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let profile = VitalzProfile(
            name: trimmedName.isEmpty ? "Friend" : trimmedName,
            dateOfBirthTimestamp: dateOfBirth.timeIntervalSince1970,
            imageData: imageData
        )
        profiles.append(profile)
        selectedProfileID = profile.id
        return profile
    }

    public func updateProfile(id: String, name: String, dateOfBirth: Date, imageData: Data?) {
        guard let index = profiles.firstIndex(where: { $0.id == id }) else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profiles[index].name = trimmedName.isEmpty ? "Me" : trimmedName
        profiles[index].dateOfBirthTimestamp = dateOfBirth.timeIntervalSince1970
        profiles[index].imageData = imageData
    }

    public func deleteProfile(id: String) {
        guard profiles.count > 1 else { return }
        profiles.removeAll { $0.id == id }
        if selectedProfileID == id {
            selectedProfileID = profiles[0].id
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        defaults.set(data, forKey: profilesKey)
        saveLegacySelectedProfile()
    }

    private func saveSelectedProfileID() {
        defaults.set(selectedProfileID, forKey: selectedProfileIDKey)
    }

    private func saveLegacySelectedProfile() {
        let selected = selectedProfile
        defaults.set(selected.name, forKey: legacyNameKey)
        defaults.set(selected.dateOfBirthTimestamp, forKey: legacyDOBKey)
    }

    private static func loadProfiles(from defaults: UserDefaults, key: String) -> [VitalzProfile] {
        guard let data = defaults.data(forKey: key),
              let profiles = try? JSONDecoder().decode([VitalzProfile].self, from: data) else {
            return []
        }
        return profiles
    }
}
