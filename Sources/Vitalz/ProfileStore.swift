import Combine
import Foundation

public struct VitalzProfile: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var dateOfBirthTimestamp: Double
    public var imageData: Data?
    public var birthTimeTimestamp: Double?
    public var birthCity: String
    public var hobbies: [Hobby]
    public var trackedPeople: [TrackedPerson]
    public var heightCentimeters: Double?
    public var readingSpeed: ReadingSpeed?

    // Legacy single-hobby/person fields kept for backward compat
    // These read from / write to the first element in the arrays.
    public var passionTitle: String {
        get { hobbies.first?.title ?? "" }
        set {
            if hobbies.isEmpty {
                hobbies.append(Hobby(title: newValue, startTimestamp: Date().timeIntervalSince1970, hoursPerWeek: 5))
            } else {
                hobbies[0].title = newValue
            }
        }
    }
    public var passionStartTimestamp: Double? {
        get { hobbies.first?.startTimestamp }
        set {
            if let v = newValue {
                if hobbies.isEmpty {
                    hobbies.append(Hobby(title: "", startTimestamp: v, hoursPerWeek: 5))
                } else {
                    hobbies[0].startTimestamp = v
                }
            } else if !hobbies.isEmpty {
                hobbies.removeFirst()
            }
        }
    }
    public var passionHoursPerWeek: Double {
        get { hobbies.first?.hoursPerWeek ?? 5 }
        set {
            if !hobbies.isEmpty { hobbies[0].hoursPerWeek = newValue }
        }
    }
    public var favoritePersonName: String {
        get { trackedPeople.first?.name ?? "" }
        set {
            if trackedPeople.isEmpty {
                trackedPeople.append(TrackedPerson(name: newValue, metTimestamp: Date().timeIntervalSince1970))
            } else {
                trackedPeople[0].name = newValue
            }
        }
    }
    public var favoritePersonMetTimestamp: Double? {
        get { trackedPeople.first?.metTimestamp }
        set {
            if let v = newValue {
                if trackedPeople.isEmpty {
                    trackedPeople.append(TrackedPerson(name: "", metTimestamp: v))
                } else {
                    trackedPeople[0].metTimestamp = v
                }
            } else if !trackedPeople.isEmpty {
                trackedPeople.removeFirst()
            }
        }
    }

    public init(
        id: String = UUID().uuidString,
        name: String,
        dateOfBirthTimestamp: Double,
        imageData: Data? = nil,
        birthTimeTimestamp: Double? = nil,
        birthCity: String = "",
        hobbies: [Hobby] = [],
        trackedPeople: [TrackedPerson] = [],
        heightCentimeters: Double? = nil,
        readingSpeed: ReadingSpeed? = nil
    ) {
        self.id = id
        self.name = name
        self.dateOfBirthTimestamp = dateOfBirthTimestamp
        self.imageData = imageData
        self.birthTimeTimestamp = birthTimeTimestamp
        self.birthCity = birthCity
        self.hobbies = hobbies
        self.trackedPeople = trackedPeople
        self.heightCentimeters = heightCentimeters
        self.readingSpeed = readingSpeed
    }

    // MARK: - Codable Migration

    private enum CodingKeys: String, CodingKey {
        case id, name, dateOfBirthTimestamp, imageData, birthTimeTimestamp, birthCity
        case hobbies, trackedPeople, heightCentimeters, readingSpeed
        // Legacy keys
        case passionTitle, passionStartTimestamp, passionHoursPerWeek
        case favoritePersonName, favoritePersonMetTimestamp
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        dateOfBirthTimestamp = try c.decode(Double.self, forKey: .dateOfBirthTimestamp)
        imageData = try c.decodeIfPresent(Data.self, forKey: .imageData)
        birthTimeTimestamp = try c.decodeIfPresent(Double.self, forKey: .birthTimeTimestamp)
        birthCity = try c.decodeIfPresent(String.self, forKey: .birthCity) ?? ""
        heightCentimeters = try c.decodeIfPresent(Double.self, forKey: .heightCentimeters)
        readingSpeed = try c.decodeIfPresent(ReadingSpeed.self, forKey: .readingSpeed)

        // Try new arrays first, fall back to legacy single fields
        if let h = try? c.decode([Hobby].self, forKey: .hobbies) {
            hobbies = h
        } else {
            // Migrate from legacy
            let title = try c.decodeIfPresent(String.self, forKey: .passionTitle) ?? ""
            let start = try c.decodeIfPresent(Double.self, forKey: .passionStartTimestamp)
            let hours = try c.decodeIfPresent(Double.self, forKey: .passionHoursPerWeek) ?? 5
            if let start, !title.isEmpty {
                hobbies = [Hobby(title: title, startTimestamp: start, hoursPerWeek: hours)]
            } else {
                hobbies = []
            }
        }

        if let p = try? c.decode([TrackedPerson].self, forKey: .trackedPeople) {
            trackedPeople = p
        } else {
            // Migrate from legacy
            let pName = try c.decodeIfPresent(String.self, forKey: .favoritePersonName) ?? ""
            let pMet = try c.decodeIfPresent(Double.self, forKey: .favoritePersonMetTimestamp)
            if let pMet, !pName.isEmpty {
                trackedPeople = [TrackedPerson(name: pName, metTimestamp: pMet)]
            } else {
                trackedPeople = []
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(dateOfBirthTimestamp, forKey: .dateOfBirthTimestamp)
        try c.encodeIfPresent(imageData, forKey: .imageData)
        try c.encodeIfPresent(birthTimeTimestamp, forKey: .birthTimeTimestamp)
        try c.encode(birthCity, forKey: .birthCity)
        try c.encode(hobbies, forKey: .hobbies)
        try c.encode(trackedPeople, forKey: .trackedPeople)
        try c.encodeIfPresent(heightCentimeters, forKey: .heightCentimeters)
        try c.encodeIfPresent(readingSpeed, forKey: .readingSpeed)
    }

    public var dateOfBirth: Date {
        Date(timeIntervalSince1970: dateOfBirthTimestamp)
    }

    public var birthTime: Date? {
        birthTimeTimestamp.map(Date.init(timeIntervalSince1970:))
    }

    public var effectiveDateOfBirth: Date {
        guard let birthTime else { return dateOfBirth }

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: dateOfBirth)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: birthTime)

        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute

        return calendar.date(from: combinedComponents) ?? dateOfBirth
    }

    public var passionStartDate: Date? {
        hobbies.first.map { Date(timeIntervalSince1970: $0.startTimestamp) }
    }

    public var favoritePersonMetDate: Date? {
        trackedPeople.first.map { Date(timeIntervalSince1970: $0.metTimestamp) }
    }
}

public enum ReadingSpeed: String, CaseIterable, Codable, Identifiable {
    case slow
    case average
    case fast

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .slow: return "Slow"
        case .average: return "Average"
        case .fast: return "Fast"
        }
    }

    public var wordsPerMinute: Int {
        switch self {
        case .slow: return 150
        case .average: return 225
        case .fast: return 320
        }
    }
}

// MARK: - Hobby

public struct Hobby: Codable, Identifiable, Equatable {
    public let id: String
    public var title: String
    public var startTimestamp: Double
    public var hoursPerWeek: Double
    public var isEnabled: Bool
    public var icon: String

    public init(
        id: String = UUID().uuidString,
        title: String,
        startTimestamp: Double,
        hoursPerWeek: Double = 5,
        isEnabled: Bool = true,
        icon: String = "sparkles"
    ) {
        self.id = id
        self.title = title
        self.startTimestamp = startTimestamp
        self.hoursPerWeek = hoursPerWeek
        self.isEnabled = isEnabled
        self.icon = icon
    }

    public var startDate: Date {
        Date(timeIntervalSince1970: startTimestamp)
    }
}

// MARK: - Tracked Person

public struct TrackedPerson: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var metTimestamp: Double
    public var dateOfBirthTimestamp: Double?
    public var imageData: Data?
    public var relationship: String

    public init(
        id: String = UUID().uuidString,
        name: String,
        metTimestamp: Double,
        dateOfBirthTimestamp: Double? = nil,
        imageData: Data? = nil,
        relationship: String = "Friend"
    ) {
        self.id = id
        self.name = name
        self.metTimestamp = metTimestamp
        self.dateOfBirthTimestamp = dateOfBirthTimestamp
        self.imageData = imageData
        self.relationship = relationship
    }

    public var metDate: Date {
        Date(timeIntervalSince1970: metTimestamp)
    }

    public var dateOfBirth: Date? {
        dateOfBirthTimestamp.map(Date.init(timeIntervalSince1970:))
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

    public func saveProfile(_ profile: VitalzProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index] = profile
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
