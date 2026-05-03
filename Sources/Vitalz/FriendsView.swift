import SwiftUI

public struct FriendsView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @State private var selectedPerson: TrackedPerson?
    @State private var showingAddPerson = false
    @State private var showingSignature = false
    @State private var showingScanner = false

    public init() {}

    private var topFade: some View {
        LinearGradient(
            colors: [
                .vitalzBackground,
                .vitalzBackground.opacity(0.88),
                .vitalzBackground.opacity(0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 72)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }

    public var body: some View {
        ZStack {
            Color.vitalzBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Orbit")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.vitalzText)

                            let count = profileStore.selectedProfile.trackedPeople.count
                            Text("^[\(count) person](inflect: true) tracked")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.vitalzSecondaryText)
                        }

                        Spacer()

                        HStack(spacing: 10) {
                            VitalzGlassButton(shape: .circle, isProminent: false) {
                                showingScanner = true
                            } content: {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 16, weight: .bold))
                                    .padding(12)
                            }

                            VitalzGlassButton(shape: .circle, isProminent: false) {
                                showingSignature = true
                            } content: {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 16, weight: .bold))
                                    .padding(12)
                            }

                            VitalzGlassButton(shape: .circle, isProminent: true) {
                                showingAddPerson = true
                            } content: {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .padding(12)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    if profileStore.selectedProfile.trackedPeople.isEmpty {
                        VStack(spacing: 24) {
                            Image("VitalzLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                                .opacity(0.8)
                            
                            VStack(spacing: 8) {
                                Text("Your Orbit is empty.")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.vitalzText)
                                
                                Text("Add friends to track your shared journey.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.vitalzSecondaryText)
                            }
                            
                            Button(action: { showingAddPerson = true }) {
                                Text("Add Friend")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.vitalzAccent)
                                    .cornerRadius(20)
                            }
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        .padding(.bottom, 100)
                    } else {
                        // Grid
                        let columns = [GridItem(.flexible()), GridItem(.flexible())]

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(profileStore.selectedProfile.trackedPeople) { person in
                                PersonCard(person: person)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedPerson = person
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .overlay(alignment: .top) {
                topFade
            }

            // Detail Sheet Overlay
            if let person = selectedPerson {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { selectedPerson = nil }
                    }

                FriendDetailView(person: person) {
                    withAnimation { selectedPerson = nil }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .sheet(isPresented: $showingAddPerson) {
            AddPersonView()
                .environmentObject(profileStore)
        }
        .fullScreenCover(isPresented: $showingSignature) {
            VitalzSignatureView()
                .environmentObject(profileStore)
        }
        .fullScreenCover(isPresented: $showingScanner) {
            SignatureScannerView()
                .environmentObject(profileStore)
        }
    }
}

struct PersonCard: View {
    let person: TrackedPerson

    var sharedDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: person.metDate)
        let end = calendar.startOfDay(for: Date())
        return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
    }

    var body: some View {
        VStack(spacing: 12) {
            ProfileAvatarView(imageData: person.imageData, size: 64)
                .overlay(
                    Circle()
                        .stroke(Color.vitalzCard, lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

            VStack(spacing: 4) {
                Text(person.name.isEmpty ? "Friend" : person.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.vitalzText)
                    .lineLimit(1)

                Text(person.relationship.isEmpty ? "Friend" : person.relationship)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.vitalzSecondaryText)
            }

            VStack(spacing: 2) {
                Text("\(sharedDays, format: .number)")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(Color.vitalzAccent)

                Text("days")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.vitalzSecondaryText)
                    .textCase(.uppercase)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(Color.vitalzCard)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.15), radius: 15, y: 8)
    }
}

struct AddPersonView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var relationship: String = ""
    @State private var metDate: Date = Date()
    @State private var hasDOB: Bool = false
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Person Details") {
                    TextField("Name", text: $name)
                    TextField("Relationship (e.g. Partner, Friend)", text: $relationship)
                }

                Section("Timeline") {
                    DatePicker("Date you met", selection: $metDate, in: ...Date(), displayedComponents: [.date])
                }

                Section("Birthday (Optional)") {
                    Toggle("I know their birthday", isOn: $hasDOB)
                    if hasDOB {
                        DatePicker("Date of Birth", selection: $dateOfBirth, in: ...Date(), displayedComponents: [.date])
                    }
                }
            }
            .navigationTitle("Add to Orbit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        save()
                    }
                    .fontWeight(.bold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        var profile = profileStore.selectedProfile
        let newPerson = TrackedPerson(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            metTimestamp: metDate.timeIntervalSince1970,
            dateOfBirthTimestamp: hasDOB ? dateOfBirth.timeIntervalSince1970 : nil,
            relationship: relationship.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        profile.trackedPeople.append(newPerson)
        profileStore.saveProfile(profile)
        dismiss()
    }
}

#Preview {
    FriendsView()
        .environmentObject(ProfileStore())
}
