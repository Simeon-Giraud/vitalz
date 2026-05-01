import PhotosUI
import SwiftUI
import UIKit

public struct SettingsView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @Environment(\.dismiss) private var dismiss

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("appTheme") private var appTheme: Int = 0 // 0: System, 1: Light, 2: Dark

    @AppStorage("showSecondsAlive") private var showSecondsAlive: Bool = true
    @AppStorage("showHeartbeats") private var showHeartbeats: Bool = true
    @AppStorage("showBreathsTaken") private var showBreathsTaken: Bool = true
    @AppStorage("showTimesBlinked") private var showTimesBlinked: Bool = true
    @AppStorage("showHairGrowth") private var showHairGrowth: Bool = true
    @AppStorage("showSpaceTraveler") private var showSpaceTraveler: Bool = true
    @AppStorage("useMetricUnits") private var useMetricUnits: Bool = true
    @AppStorage("syncHealthApp") private var syncHealthApp: Bool = false

    @State private var selectedTab = 1
    @State private var editingProfile: VitalzProfile?
    @State private var isAddingProfile = false

    public init() {}

    public var body: some View {
        ZStack {
            Color.vitalzBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                tabs

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        if selectedTab == 0 {
                            appearanceSection
                        } else if selectedTab == 1 {
                            dashboardSection
                        } else {
                            profilesSection
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.large])
        .onChange(of: syncHealthApp) { newValue in
            if newValue {
                Task {
                    let success = await HealthKitManager.shared.requestAuthorization()
                    if !success {
                        syncHealthApp = false
                    }
                }
            }
        }
        .sheet(item: $editingProfile) { profile in
            ProfileEditorView(profile: profile)
                .environmentObject(profileStore)
        }
        .sheet(isPresented: $isAddingProfile) {
            ProfileEditorView(profile: nil)
                .environmentObject(profileStore)
        }
    }

    private var header: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.vitalzText)

            Spacer()

            VitalzGlassButton(shape: .circle, isProminent: false, action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.vitalzSecondaryText)
                    .padding(10)
            }
        }
        .padding(24)
    }

    private var tabs: some View {
        HStack(spacing: 8) {
            TabButton(title: "Appearance", isSelected: selectedTab == 0) { selectedTab = 0 }
            TabButton(title: "Dashboard", isSelected: selectedTab == 1) { selectedTab = 1 }
            TabButton(title: "Profiles", isSelected: selectedTab == 2) { selectedTab = 2 }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Theme", selection: $appTheme) {
                Text("System").tag(0)
                Text("Light").tag(1)
                Text("Dark").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(16)
            .background(Color.vitalzCard)
            .cornerRadius(16)
        }
    }

    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Units")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.vitalzSecondaryText)

                HStack(spacing: 12) {
                    UnitChoiceButton(
                        title: "Metric",
                        subtitle: "km, m, cm",
                        isSelected: useMetricUnits,
                        action: { useMetricUnits = true }
                    )

                    UnitChoiceButton(
                        title: "Imperial",
                        subtitle: "mi, ft, in",
                        isSelected: !useMetricUnits,
                        action: { useMetricUnits = false }
                    )
                }
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("Integrations")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                
                HStack(spacing: 16) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .frame(width: 24)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Apple Health")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Text("Sync for precise live stats")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $syncHealthApp)
                        .labelsHidden()
                        .tint(.blue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(white: 0.15))
                .cornerRadius(16)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("Manage Visibility")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.vitalzSecondaryText)

                VStack(spacing: 0) {
                    ToggleRow(title: "Seconds Alive", isOn: $showSecondsAlive)
                    Divider().background(Color.vitalzDivider).padding(.leading, 56)
                    ToggleRow(title: "Heartbeats", isOn: $showHeartbeats)
                    Divider().background(Color.vitalzDivider).padding(.leading, 56)
                    ToggleRow(title: "Breaths Taken", isOn: $showBreathsTaken)
                    Divider().background(Color.vitalzDivider).padding(.leading, 56)
                    ToggleRow(title: "Times Blinked", isOn: $showTimesBlinked)
                    Divider().background(Color.vitalzDivider).padding(.leading, 56)
                    ToggleRow(title: "Hair Growth", isOn: $showHairGrowth)
                    Divider().background(Color.vitalzDivider).padding(.leading, 56)
                    ToggleRow(title: "Space Traveler", isOn: $showSpaceTraveler)
                }
                .background(Color.vitalzCard)
                .cornerRadius(16)
            }

            VitalzGlassButton(shape: .rounded(16), isProminent: false, action: resetIdentity) {
                Text("Reset Identity")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
        }
    }

    private var profilesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("People")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.vitalzSecondaryText)

            VStack(spacing: 0) {
                ForEach(profileStore.profiles) { profile in
                    ProfileRow(
                        profile: profile,
                        isSelected: profile.id == profileStore.selectedProfileID,
                        canDelete: profileStore.profiles.count > 1,
                        onSelect: { profileStore.selectProfile(id: profile.id) },
                        onEdit: { editingProfile = profile },
                        onDelete: { profileStore.deleteProfile(id: profile.id) }
                    )

                    if profile.id != profileStore.profiles.last?.id {
                        Divider().background(Color.vitalzDivider).padding(.leading, 76)
                    }
                }
            }
            .background(Color.vitalzCard)
            .cornerRadius(16)

            VitalzGlassButton(shape: .rounded(16), isProminent: false, action: { isAddingProfile = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Profile")
                    Spacer()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.vitalzBlue)
                .padding(16)
            }
        }
    }

    private func resetIdentity() {
        withAnimation(.easeInOut(duration: 0.8)) {
            hasCompletedOnboarding = false
        }
    }
}

struct ProfileRow: View {
    let profile: VitalzProfile
    let isSelected: Bool
    let canDelete: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onSelect) {
                HStack(spacing: 14) {
                    ProfileAvatarView(imageData: profile.imageData, size: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.vitalzText)

                        Text("Born \(formattedDate(profile.dateOfBirth))")
                            .font(.system(size: 13))
                            .foregroundColor(.vitalzSecondaryText)
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? .vitalzBlue : .vitalzSecondaryText)
                }
            }
            .buttonStyle(.plain)

            Menu {
                Button("Edit", action: onEdit)

                if canDelete {
                    Button("Delete", role: .destructive, action: onDelete)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.vitalzSecondaryText)
            }
        }
        .padding(14)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct UnitChoiceButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VitalzGlassButton(shape: .rounded(16), isProminent: isSelected, action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                }

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.vitalzSecondaryText)
            }
            .foregroundColor(isSelected ? .white : .vitalzText)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ProfileEditorView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @Environment(\.dismiss) private var dismiss

    private let profile: VitalzProfile?

    @State private var name: String
    @State private var dateOfBirth: Date
    @State private var imageData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var hasBirthTime: Bool
    @State private var birthTime: Date
    @State private var birthCity: String
    @State private var hasPassion: Bool
    @State private var passionTitle: String
    @State private var passionStartDate: Date
    @State private var passionHoursPerWeek: Double
    @State private var hasFavoritePerson: Bool
    @State private var favoritePersonName: String
    @State private var favoritePersonMetDate: Date
    @State private var heightCentimetersText: String
    @State private var readingSpeed: ReadingSpeed?

    init(profile: VitalzProfile?) {
        self.profile = profile
        _name = State(initialValue: profile?.name ?? "Friend")
        _dateOfBirth = State(initialValue: profile?.dateOfBirth ?? Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date())
        _imageData = State(initialValue: profile?.imageData)
        _hasBirthTime = State(initialValue: profile?.birthTimeTimestamp != nil)
        _birthTime = State(initialValue: profile?.birthTime ?? Date())
        _birthCity = State(initialValue: profile?.birthCity ?? "")
        _hasPassion = State(initialValue: profile?.passionStartTimestamp != nil)
        _passionTitle = State(initialValue: profile?.passionTitle ?? "")
        _passionStartDate = State(initialValue: profile?.passionStartDate ?? Date())
        _passionHoursPerWeek = State(initialValue: profile?.passionHoursPerWeek ?? 5)
        _hasFavoritePerson = State(initialValue: profile?.favoritePersonMetTimestamp != nil)
        _favoritePersonName = State(initialValue: profile?.favoritePersonName ?? "")
        _favoritePersonMetDate = State(initialValue: profile?.favoritePersonMetDate ?? Date())
        _heightCentimetersText = State(initialValue: profile?.heightCentimeters.map { String(format: "%.0f", $0) } ?? "")
        _readingSpeed = State(initialValue: profile?.readingSpeed)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                ProfileAvatarView(imageData: imageData, size: 96)

                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.vitalzBlue)
                                    .clipShape(Circle())
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 12)
                }

                Section {
                    TextField("Name", text: $name)
                    DatePicker("Birthday", selection: $dateOfBirth, in: ...Date(), displayedComponents: [.date])
                }

                Section("Birth Details") {
                    Toggle("I know the birth time", isOn: $hasBirthTime)

                    if hasBirthTime {
                        DatePicker("Birth Time", selection: $birthTime, displayedComponents: [.hourAndMinute])
                    }

                    TextField("Birth City", text: $birthCity)
                        .textContentType(.addressCity)
                }

                Section("Day Zero") {
                    Toggle("Track a passion or era", isOn: $hasPassion)

                    if hasPassion {
                        TextField("Started playing piano, moved to London...", text: $passionTitle)
                        DatePicker("Start Date", selection: $passionStartDate, in: ...Date(), displayedComponents: [.date])

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weekly dedication: \(Int(passionHoursPerWeek))h")
                                .foregroundColor(.vitalzSecondaryText)

                            Slider(value: $passionHoursPerWeek, in: 1...40, step: 1)
                        }
                    }
                }

                Section("Shared Orbit") {
                    Toggle("Track a favorite person", isOn: $hasFavoritePerson)

                    if hasFavoritePerson {
                        TextField("Name", text: $favoritePersonName)
                        DatePicker("Date You Met", selection: $favoritePersonMetDate, in: ...Date(), displayedComponents: [.date])
                    }
                }

                Section("Biological Baselines") {
                    TextField("Height in cm", text: $heightCentimetersText)
                        .keyboardType(.decimalPad)

                    Picker("Reading Speed", selection: $readingSpeed) {
                        Text("Not set").tag(ReadingSpeed?.none)

                        ForEach(ReadingSpeed.allCases) { speed in
                            Text(speed.title).tag(ReadingSpeed?.some(speed))
                        }
                    }
                }

                if imageData != nil {
                    Section {
                        VitalzGlassButton(shape: .rounded(14), isProminent: false, action: {
                            imageData = nil
                        }) {
                            Text("Remove Photo")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                    }
                }
            }
            .navigationTitle(profile == nil ? "Add Profile" : "Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.gray)
                            .symbolRenderingMode(.hierarchical)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    VitalzGlassButton(shape: .capsule, isProminent: true, action: save) {
                        Text("Save")
                    }
                }
            }
            .task(id: selectedPhotoItem) {
                await loadSelectedPhoto()
            }
        }
    }

    private func save() {
        let trimmedCity = birthCity.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassion = passionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFavoritePerson = favoritePersonName.trimmingCharacters(in: .whitespacesAndNewlines)
        let heightCentimeters = Double(heightCentimetersText.replacingOccurrences(of: ",", with: "."))

        if let profile {
            var updatedProfile = profile
            updatedProfile.name = sanitizedName(fallback: "Me")
            updatedProfile.dateOfBirthTimestamp = dateOfBirth.timeIntervalSince1970
            updatedProfile.imageData = imageData
            updatedProfile.birthTimeTimestamp = hasBirthTime ? birthTime.timeIntervalSince1970 : nil
            updatedProfile.birthCity = trimmedCity
            updatedProfile.passionTitle = hasPassion ? trimmedPassion : ""
            updatedProfile.passionStartTimestamp = hasPassion ? passionStartDate.timeIntervalSince1970 : nil
            updatedProfile.passionHoursPerWeek = passionHoursPerWeek
            updatedProfile.favoritePersonName = hasFavoritePerson ? trimmedFavoritePerson : ""
            updatedProfile.favoritePersonMetTimestamp = hasFavoritePerson ? favoritePersonMetDate.timeIntervalSince1970 : nil
            updatedProfile.heightCentimeters = heightCentimeters
            updatedProfile.readingSpeed = readingSpeed
            profileStore.saveProfile(updatedProfile)
        } else {
            var newProfile = profileStore.addProfile(
                name: sanitizedName(fallback: "Friend"),
                dateOfBirth: dateOfBirth,
                imageData: imageData
            )
            newProfile.birthTimeTimestamp = hasBirthTime ? birthTime.timeIntervalSince1970 : nil
            newProfile.birthCity = trimmedCity
            newProfile.passionTitle = hasPassion ? trimmedPassion : ""
            newProfile.passionStartTimestamp = hasPassion ? passionStartDate.timeIntervalSince1970 : nil
            newProfile.passionHoursPerWeek = passionHoursPerWeek
            newProfile.favoritePersonName = hasFavoritePerson ? trimmedFavoritePerson : ""
            newProfile.favoritePersonMetTimestamp = hasFavoritePerson ? favoritePersonMetDate.timeIntervalSince1970 : nil
            newProfile.heightCentimeters = heightCentimeters
            newProfile.readingSpeed = readingSpeed
            profileStore.saveProfile(newProfile)
        }

        dismiss()
    }

    private func sanitizedName(fallback: String) -> String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? fallback : trimmedName
    }

    private func loadSelectedPhoto() async {
        guard let selectedPhotoItem,
              let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) else {
            return
        }

        if let image = UIImage(data: data),
           let compressedData = image.jpegData(compressionQuality: 0.75) {
            imageData = compressedData
        } else {
            imageData = data
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VitalzGlassButton(shape: .capsule, isProminent: isSelected, action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .vitalzSecondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "eye")
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.vitalzText)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ProfileStore())
}
