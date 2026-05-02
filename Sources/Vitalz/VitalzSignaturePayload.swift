import Foundation

// MARK: - Vitalz Signature Payload

/// A lightweight, self-contained payload that encodes a user's shareable profile.
/// Designed for offline QR code and deep link transmission — zero server dependency.
public struct VitalzSignature: Codable, Equatable {

    /// The shared first name of the sender.
    public let name: String

    /// The sender's date of birth as a Unix timestamp.
    public let dateOfBirthTimestamp: Double

    /// The subset of hobbies the sender chose to share.
    public let hobbies: [SharedHobby]

    /// A minimal hobby representation stripped of internal IDs and toggle state.
    public struct SharedHobby: Codable, Equatable, Identifiable {
        public var id: String { title + String(startTimestamp) }
        public let title: String
        public let startTimestamp: Double
        public let hoursPerWeek: Double
        public let icon: String

        public init(title: String, startTimestamp: Double, hoursPerWeek: Double, icon: String) {
            self.title = title
            self.startTimestamp = startTimestamp
            self.hoursPerWeek = hoursPerWeek
            self.icon = icon
        }

        /// Convert back to a full Hobby for import into ProfileStore.
        public func toHobby() -> Hobby {
            Hobby(
                title: title,
                startTimestamp: startTimestamp,
                hoursPerWeek: hoursPerWeek,
                isEnabled: true,
                icon: icon
            )
        }
    }

    public init(name: String, dateOfBirthTimestamp: Double, hobbies: [SharedHobby]) {
        self.name = name
        self.dateOfBirthTimestamp = dateOfBirthTimestamp
        self.hobbies = hobbies
    }

    /// Convenience initializer from a VitalzProfile, filtering to selected hobby IDs.
    public init(profile: VitalzProfile, selectedHobbyIDs: Set<String>) {
        self.name = profile.name
        self.dateOfBirthTimestamp = profile.dateOfBirthTimestamp
        self.hobbies = profile.hobbies
            .filter { selectedHobbyIDs.contains($0.id) }
            .map { SharedHobby(title: $0.title, startTimestamp: $0.startTimestamp, hoursPerWeek: $0.hoursPerWeek, icon: $0.icon) }
    }

    // MARK: - Encoding

    /// Encodes the signature to a URL-safe Base64 string.
    public func encode() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        return jsonData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Builds a full deep link URL from the encoded payload.
    public func deepLink() -> URL? {
        guard let encoded = encode() else { return nil }
        return URL(string: "vitalz://signature?data=\(encoded)")
    }

    // MARK: - Decoding

    /// Decodes a VitalzSignature from a URL-safe Base64 string.
    public static func decode(from base64String: String) -> VitalzSignature? {
        // Restore standard Base64
        var restored = base64String
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Re-pad
        let remainder = restored.count % 4
        if remainder > 0 {
            restored += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: restored) else { return nil }
        return try? JSONDecoder().decode(VitalzSignature.self, from: data)
    }

    /// Extracts and decodes a signature from a vitalz:// deep link URL.
    public static func decode(from url: URL) -> VitalzSignature? {
        guard url.scheme == "vitalz",
              url.host == "signature",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let dataParam = components.queryItems?.first(where: { $0.name == "data" })?.value
        else { return nil }
        return decode(from: dataParam)
    }
}
