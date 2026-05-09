import SwiftUI

/// Wrapper around `SignaturePreviewSheet` to handle deep-link imports outside the scanner view.
public struct DeepLinkImportView: View {
    let signature: VitalzSignature
    
    @EnvironmentObject private var profileStore: ProfileStore
    @Environment(\.dismiss) private var dismiss
    
    public init(signature: VitalzSignature) {
        self.signature = signature
    }
    
    public var body: some View {
        SignaturePreviewSheet(signature: signature) {
            addToOrbit(signature)
            dismiss()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func addToOrbit(_ signature: VitalzSignature) {
        var profile = profileStore.selectedProfile

        // Add as a tracked person
        let person = TrackedPerson(
            name: signature.name,
            metTimestamp: Date().timeIntervalSince1970,
            dateOfBirthTimestamp: signature.dateOfBirthTimestamp,
            relationship: "Friend"
        )
        profile.trackedPeople.append(person)

        // Import their shared hobbies as the user's own (disabled by default so they don't pollute Era Share)
        for sharedHobby in signature.hobbies {
            let hobby = Hobby(
                title: sharedHobby.title,
                startTimestamp: sharedHobby.startTimestamp,
                hoursPerWeek: sharedHobby.hoursPerWeek,
                isEnabled: false,
                icon: sharedHobby.icon
            )
            // Only add if not already tracking this hobby title
            if !profile.hobbies.contains(where: { $0.title.lowercased() == hobby.title.lowercased() }) {
                profile.hobbies.append(hobby)
            }
        }

        profileStore.saveProfile(profile)
    }
}
