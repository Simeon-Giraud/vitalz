import PhotosUI
import SwiftUI
import UIKit

public struct SettingsView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @Environment(\.dismiss) private var dismiss

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("appTheme") private var appTheme: Int = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("wallpaperTheme") private var wallpaperThemeRaw: String = WallpaperTheme.standardLight.rawValue
    @AppStorage("accentTheme") private var accentTheme: String = AccentTheme.electricBlue.rawValue

    @AppStorage("showSecondsAlive") private var showSecondsAlive: Bool = true
    @AppStorage("showHeartbeats") private var showHeartbeats: Bool = true
    @AppStorage("showBreathsTaken") private var showBreathsTaken: Bool = true
    @AppStorage("showTimesBlinked") private var showTimesBlinked: Bool = true
    @AppStorage("showHairGrowth") private var showHairGrowth: Bool = true
    @AppStorage("showSpaceTraveler") private var showSpaceTraveler: Bool = true
    @AppStorage("useMetricUnits") private var useMetricUnits: Bool = true
    @AppStorage("syncHealthApp") private var syncHealthApp: Bool = false
    @AppStorage("averageScreenTime") private var averageScreenTime: Double = 0.0
    @AppStorage("dailyCoffeeCups") private var dailyCoffeeCups: Int = 0

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

                        // Footer Logo
                        VStack(spacing: 6) {
                            Image("VitalzLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)
                                .opacity(0.8)
                            
                            Text("VITALZ")
                                .font(.caption2)
                                .kerning(2)
                                .foregroundColor(.vitalzSecondaryText)
                        }
                        .padding(.top, 40)
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

    private var selectedAccent: AccentTheme {
        AccentTheme(rawValue: accentTheme) ?? .electricBlue
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Wallpaper Theme Swatches
            VStack(alignment: .leading, spacing: 12) {
                Text("Wallpaper")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.vitalzSecondaryText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(WallpaperTheme.allCases) { theme in
                            Button {
                                HapticEngine.playMechanicalClick()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    wallpaperThemeRaw = theme.rawValue
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(theme.textColor == .white ? Color.black : Color.white)
                                            .overlay(theme.backgroundView.clipShape(RoundedRectangle(cornerRadius: 16)))
                                            .frame(width: 80, height: 120)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)

                                        if wallpaperThemeRaw == theme.rawValue {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.vitalzText, lineWidth: 2)
                                                .frame(width: 88, height: 128)

                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(theme.textColor)
                                        }
                                    }
                                    Text(theme.displayName)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(wallpaperThemeRaw == theme.rawValue ? .vitalzText : .vitalzSecondaryText)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                }
            }
            
            // Accent Color Picker
            VStack(alignment: .leading, spacing: 12) {
                Text("Accent Color")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.vitalzSecondaryText)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(AccentTheme.allCases) { theme in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                accentTheme = theme.rawValue
                            }
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(theme.color)
                                        .frame(width: 44, height: 44)
                                    
                                    if selectedAccent == theme {
                                        Circle()
                                            .stroke(Color.vitalzText, lineWidth: 2.5)
                                            .frame(width: 52, height: 52)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Text(theme.rawValue.components(separatedBy: " ").first ?? theme.rawValue)
                                    .font(.system(size: 10, weight: selectedAccent == theme ? .bold : .medium))
                                    .foregroundColor(selectedAccent == theme ? .vitalzText : .vitalzSecondaryText)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.vitalzCard)
                .cornerRadius(16)
            }
            
            // Card Color Legend
            VStack(alignment: .leading, spacing: 12) {
                Text("Card Colors")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.vitalzSecondaryText)
                
                Text("Cards are color-coded by category to help you scan your dashboard at a glance.")
                    .font(.system(size: 12))
                    .foregroundColor(.vitalzSecondaryText.opacity(0.7))
                
                VStack(spacing: 0) {
                    ForEach([CardCategory.body, .time, .cosmos, .mind, .growth, .bonds], id: \.rawValue) { cat in
                        HStack(spacing: 14) {
                            Circle()
                                .fill(cat.accentColor)
                                .frame(width: 12, height: 12)
                            
                            Image(systemName: cat.icon)
                                .font(.system(size: 14))
                                .foregroundColor(cat.accentColor)
                                .frame(width: 20)
                            
                            Text(cat.label)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.vitalzText)
                            
                            Spacer()
                            
                            Text(categoryDescription(cat))
                                .font(.system(size: 12))
                                .foregroundColor(.vitalzSecondaryText)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        
                        if cat != .bonds {
                            Divider()
                                .background(Color.vitalzDivider)
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(Color.vitalzCard)
                .cornerRadius(16)
            }
        }
    }
    
    private func categoryDescription(_ cat: CardCategory) -> String {
        switch cat {
        case .body: return "Heart, breath, blinks"
        case .time: return "Seconds, sleep, sunsets"
        case .cosmos: return "Space, moons, planets"
        case .mind: return "Screen, coffee, reading"
        case .growth: return "Passion, mastery"
        case .bonds: return "Shared experiences"
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
                Text("Your Habits")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    // Screen Time Input
                    HStack {
                        Image(systemName: "iphone")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Daily Screen Time")
                            .foregroundColor(.white)
                        Spacer()
                        Picker("", selection: $averageScreenTime) {
                            Text("Not set").tag(0.0)
                            ForEach(Array(stride(from: 0.5, through: 12.0, by: 0.5)), id: \.self) { hours in
                                Text("\(String(format: "%.1f", hours))h").tag(hours)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(16)
                    .background(Color(white: 0.15))
                    
                    Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 16)
                    
                    // Coffee Input
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        Text("Coffee Cups / Day")
                            .foregroundColor(.white)
                        Spacer()
                        Picker("", selection: $dailyCoffeeCups) {
                            Text("Not set").tag(0)
                            ForEach(1...15, id: \.self) { count in
                                Text("\(count) \(count == 1 ? "cup" : "cups")").tag(count)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(16)
                    .background(Color(white: 0.15))
                }
                .cornerRadius(16)
                
                Text("Providing these enables the 'Phone Void' and 'Caffeine River' stats on your dashboard.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
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
    @State private var hobbies: [Hobby]
    @State private var trackedPeople: [TrackedPerson]
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
        _hobbies = State(initialValue: profile?.hobbies ?? [])
        _trackedPeople = State(initialValue: profile?.trackedPeople ?? [])
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
                                    .background(Color.vitalzAccent)
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

                // MARK: - Hobbies (Multiple)
                Section("Your Passions") {
                    ForEach($hobbies) { $hobby in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: hobby.icon)
                                    .foregroundColor(.vitalzAccent)
                                    .frame(width: 24)
                                TextField("Hobby name", text: $hobby.title)
                                    .font(.system(size: 15, weight: .medium))
                                Spacer()
                                Toggle("", isOn: $hobby.isEnabled)
                                    .labelsHidden()
                                    .tint(.vitalzAccent)
                            }

                            DatePicker("Started", selection: Binding(
                                get: { hobby.startDate },
                                set: { hobby.startTimestamp = $0.timeIntervalSince1970 }
                            ), in: ...Date(), displayedComponents: [.date])
                            .font(.system(size: 14))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Weekly: \(Int(hobby.hoursPerWeek))h")
                                    .font(.system(size: 13))
                                    .foregroundColor(.vitalzSecondaryText)
                                Slider(value: $hobby.hoursPerWeek, in: 1...40, step: 1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indices in
                        hobbies.remove(atOffsets: indices)
                    }

                    Button {
                        hobbies.append(Hobby(
                            title: "",
                            startTimestamp: Date().timeIntervalSince1970,
                            hoursPerWeek: 5
                        ))
                    } label: {
                        Label("Add Hobby", systemImage: "plus.circle.fill")
                            .foregroundColor(.vitalzAccent)
                    }
                }

                // MARK: - Tracked People (Multiple)
                Section("Your Orbit") {
                    ForEach($trackedPeople) { $person in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.vitalzAccent)
                                    .frame(width: 24)
                                TextField("Name", text: $person.name)
                                    .font(.system(size: 15, weight: .medium))
                            }

                            TextField("Relationship (Friend, Partner...)", text: $person.relationship)
                                .font(.system(size: 14))
                                .foregroundColor(.vitalzSecondaryText)

                            DatePicker("Date You Met", selection: Binding(
                                get: { person.metDate },
                                set: { person.metTimestamp = $0.timeIntervalSince1970 }
                            ), in: ...Date(), displayedComponents: [.date])
                            .font(.system(size: 14))
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indices in
                        trackedPeople.remove(atOffsets: indices)
                    }

                    Button {
                        trackedPeople.append(TrackedPerson(
                            name: "",
                            metTimestamp: Date().timeIntervalSince1970
                        ))
                    } label: {
                        Label("Add Person", systemImage: "plus.circle.fill")
                            .foregroundColor(.vitalzAccent)
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
        let heightCentimeters = Double(heightCentimetersText.replacingOccurrences(of: ",", with: "."))

        // Clean up empty hobbies/people
        let cleanedHobbies = hobbies.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let cleanedPeople = trackedPeople.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        if let profile {
            var updatedProfile = profile
            updatedProfile.name = sanitizedName(fallback: "Me")
            updatedProfile.dateOfBirthTimestamp = dateOfBirth.timeIntervalSince1970
            updatedProfile.imageData = imageData
            updatedProfile.birthTimeTimestamp = hasBirthTime ? birthTime.timeIntervalSince1970 : nil
            updatedProfile.birthCity = trimmedCity
            updatedProfile.hobbies = cleanedHobbies
            updatedProfile.trackedPeople = cleanedPeople
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
            newProfile.hobbies = cleanedHobbies
            newProfile.trackedPeople = cleanedPeople
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
                .foregroundColor(.vitalzAccent)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.vitalzText)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.vitalzAccent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ProfileStore())
}
