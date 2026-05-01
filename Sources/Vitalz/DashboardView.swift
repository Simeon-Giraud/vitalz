import SwiftUI

struct CardData: Identifiable {
    enum ID: String, Hashable {
        case secondsAlive
        case heartbeats
        case breathsTaken
        case timesBlinked
        case hairGrowth
        case spaceTraveler
        case fullMoons
        case jupiterAge
        case sleep
        case phoneVoid
        case caffeineRiver
        case sunsets
        case passionEra
        case masteryHours
        case sharedDays
        case sharedHeartbeats
        case nailGrowth
        case wordsRead
    }

    let id: ID
    let title: String
    let value: String
    let subtitle: String
    let chartData: [CGFloat]
    let icon: String
    let color: Color
    let accentColor: Color
    let valueColor: Color
    var isFullWidth: Bool = false
}

public struct DashboardView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    
    // Visibility Toggles
    @AppStorage("showSecondsAlive") private var showSecondsAlive: Bool = true
    @AppStorage("showHeartbeats") private var showHeartbeats: Bool = true
    @AppStorage("showBreathsTaken") private var showBreathsTaken: Bool = true
    @AppStorage("showTimesBlinked") private var showTimesBlinked: Bool = true
    @AppStorage("showHairGrowth") private var showHairGrowth: Bool = true
    @AppStorage("showSpaceTraveler") private var showSpaceTraveler: Bool = true
    
    @State private var currentDate = Date()
    @State private var stats: LifeStats? = nil
    @State private var showingSettings = false
    
    @Namespace private var animation
    @State private var selectedCardID: CardData.ID? = nil
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()
    
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
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        ProfileAvatarView(imageData: profileStore.selectedProfile.imageData, size: 44)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.vitalzSecondaryText)
                            
                            Text(Date(), style: .date)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.vitalzText)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20))
                                .foregroundColor(.vitalzText)
                                .padding(12)
                                .background(Color.vitalzControl)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    if let stats = stats {
                        let allCards = generateCards(from: stats, profile: profileStore.selectedProfile)
                        let topCard = visibleTopCard(from: allCards)
                        let middleCards = visibleCards(matching: activeMiddleCardIDs, from: allCards)
                        let bottomCards = visibleCards(matching: activeBottomCardIDs, from: allCards)
                        let percentageLived = stats.percentageOf80YearLifeExpectancy
                        
                        VStack(spacing: 16) {
                            if let top = topCard {
                                Button(action: { selectCard(top) }) {
                                    GridCardView(card: top, animation: animation, isSelected: selectedCardID == top.id)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(middleCards) { card in
                                    Button(action: { selectCard(card) }) {
                                        GridCardView(card: card, animation: animation, isSelected: selectedCardID == card.id)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            // Ad Space Mockup
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("SPONSORED")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.vitalzSecondaryText)
                                        .kerning(1.2)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.vitalzSecondaryText)
                                }
                                
                                Text("Your brand could be here")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.vitalzText)
                                
                                Text("Reach mindful users tracking their life stats")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.vitalzSecondaryText)
                                
                                Spacer(minLength: 20)
                                Text("ads@vitalz.app")
                                    .font(.system(size: 13))
                                    .foregroundColor(.vitalzSecondaryText.opacity(0.7))
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.vitalzCard)
                            .cornerRadius(24)
                            
                            // Life Loading Bar
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Life Loading")
                                        .font(.system(size: 15))
                                        .foregroundColor(.vitalzSecondaryText)
                                    Spacer()
                                    Image(systemName: "sun.max.fill")
                                        .foregroundColor(.vitalzSecondaryText)
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.vitalzControl)
                                            .frame(height: 12)
                                        
                                        Capsule()
                                            .fill(Color.green.opacity(0.8))
                                            .frame(width: geo.size.width * CGFloat(percentageLived / 100.0), height: 12)
                                    }
                                }
                                .frame(height: 12)
                                
                                HStack {
                                    Text("Life Completed")
                                        .font(.system(size: 15))
                                        .foregroundColor(.vitalzSecondaryText)
                                    Spacer()
                                    Text(String(format: "%.1f%%", percentageLived))
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.vitalzText)
                                }
                            }
                            .padding(24)
                            .background(Color.vitalzCard)
                            .cornerRadius(24)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(bottomCards) { card in
                                    Button(action: { selectCard(card) }) {
                                        GridCardView(card: card, animation: animation, isSelected: selectedCardID == card.id)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 80)
                    }
                }
            }
            .overlay(alignment: .top) {
                topFade
            }
            
            // Expanded Overlay
            if let selectedCardID,
               let card = stats.map({ generateCards(from: $0, profile: profileStore.selectedProfile) })?.first(where: { $0.id == selectedCardID }) {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture(perform: closeCard)
                
                ExpandedCardView(card: card, animation: animation) {
                    closeCard()
                }
                .padding(24) // Leaves space around the card so it doesn't take the full screen
                .zIndex(1)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear { updateStats(for: currentDate) }
        .onChange(of: profileStore.selectedProfileID) { _ in updateStats(for: currentDate) }
        .onChange(of: profileStore.selectedProfile.dateOfBirthTimestamp) { _ in updateStats(for: currentDate) }
        .onReceive(timer) { input in
            currentDate = input
            updateStats(for: input)
        }
    }
    
    private var activeMiddleCardIDs: [CardData.ID] {
        [
            showHeartbeats ? .heartbeats : nil,
            showBreathsTaken ? .breathsTaken : nil,
            showTimesBlinked ? .timesBlinked : nil,
            showHairGrowth ? .hairGrowth : nil
        ].compactMap { $0 }
    }

    private var activeBottomCardIDs: [CardData.ID] {
        let defaultIDs: [CardData.ID] = [
            .fullMoons,
            .jupiterAge,
            .sleep,
            .phoneVoid,
            .caffeineRiver,
            .sunsets,
            .passionEra,
            .masteryHours,
            .sharedDays,
            .sharedHeartbeats,
            .nailGrowth,
            .wordsRead
        ]
        return showSpaceTraveler ? [.spaceTraveler] + defaultIDs : defaultIDs
    }

    private func visibleTopCard(from cards: [CardData]) -> CardData? {
        guard showSecondsAlive else { return nil }
        return cards.first { $0.id == .secondsAlive }
    }

    private func visibleCards(matching ids: [CardData.ID], from cards: [CardData]) -> [CardData] {
        cards.filter { ids.contains($0.id) }
    }

    private func selectCard(_ card: CardData) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            selectedCardID = card.id
        }
    }
    
    private func closeCard() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            selectedCardID = nil
        }
    }
    
    private func updateStats(for date: Date) {
        let math = LifeMath(dateOfBirth: profileStore.selectedProfile.effectiveDateOfBirth)
        self.stats = math.calculateStats(upTo: date)
    }

    private var userName: String {
        profileStore.selectedProfile.name
    }
    
    private func formatLargeNumber(_ number: Int) -> String {
        return Self.numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    private func formatDouble(_ number: Double, decimals: Int = 1) -> String {
        return String(format: "%.\(decimals)f", number)
    }
    
    private func formatMillions(_ number: Int) -> String {
        let m = Double(number) / 1_000_000.0
        return String(format: "%.1fM", m)
    }
    
    private func formatBillions(_ number: Int) -> String {
        let b = Double(number) / 1_000_000_000.0
        return String(format: "%.1fB", b)
    }
    
    private func generateCards(from stats: LifeStats, profile: VitalzProfile) -> [CardData] {
        let ascendingData: [CGFloat] = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
        let yellowColor = Color(red: 0.2, green: 0.15, blue: 0.05)
        let redColor = Color(red: 0.2, green: 0.05, blue: 0.08)
        let purpleColor = Color(red: 0.1, green: 0.05, blue: 0.2)
        let blueColor = Color(red: 0.05, green: 0.1, blue: 0.2)
        let greenColor = Color(red: 0.04, green: 0.16, blue: 0.1)
        let tealColor = Color(red: 0.03, green: 0.14, blue: 0.16)
        
        var cards = [
            CardData(id: .secondsAlive, title: "Seconds Alive", value: formatLargeNumber(stats.totalSecondsAlive), subtitle: "and counting...", chartData: ascendingData, icon: "stopwatch", color: yellowColor, accentColor: .yellow, valueColor: .yellow, isFullWidth: true),
            CardData(id: .heartbeats, title: "Heartbeats", value: formatMillions(stats.estimatedTotalHeartbeats), subtitle: "@ 70 bpm", chartData: ascendingData, icon: "heart", color: redColor, accentColor: .red, valueColor: Color(red: 1.0, green: 0.6, blue: 0.6)),
            CardData(id: .breathsTaken, title: "Breaths Taken", value: formatMillions(stats.estimatedBreathsTaken), subtitle: "@ 16/min", chartData: ascendingData, icon: "wind", color: redColor, accentColor: .red, valueColor: Color(red: 1.0, green: 0.6, blue: 0.6)),
            CardData(id: .timesBlinked, title: "Times Blinked", value: formatMillions(stats.estimatedBlinks), subtitle: "while awake", chartData: ascendingData, icon: "eye", color: redColor, accentColor: .red, valueColor: Color(red: 1.0, green: 0.6, blue: 0.6)),
            CardData(id: .hairGrowth, title: "Hair Growth", value: formatDouble(stats.hairGrowthMeters) + "m", subtitle: "of hair grown", chartData: ascendingData, icon: "scissors", color: redColor, accentColor: .red, valueColor: Color(red: 1.0, green: 0.6, blue: 0.6)),
            CardData(id: .spaceTraveler, title: "Space Traveler", value: formatBillions(stats.distanceTraveledSpaceKm), subtitle: "km around Sun", chartData: ascendingData, icon: "location.north.fill", color: purpleColor, accentColor: .blue, valueColor: .white),
            CardData(id: .fullMoons, title: "Full Moons", value: formatLargeNumber(stats.fullMoonsWitnessed), subtitle: "witnessed", chartData: ascendingData, icon: "moon", color: purpleColor, accentColor: .blue, valueColor: .white),
            CardData(id: .jupiterAge, title: "Jupiter Age", value: formatDouble(stats.jupiterAge, decimals: 2), subtitle: "years on Jupiter", chartData: ascendingData, icon: "globe", color: purpleColor, accentColor: .blue, valueColor: .white),
            CardData(id: .sleep, title: "Sleep", value: formatDouble(stats.estimatedHoursSlept / 24.0 / 365.25) + " yrs", subtitle: "spent dreaming", chartData: ascendingData, icon: "moon.zzz", color: blueColor, accentColor: .blue, valueColor: .white),
            CardData(id: .phoneVoid, title: "Phone Void", value: formatDouble(stats.phoneVoidYears) + " yrs", subtitle: "lost to screens", chartData: ascendingData, icon: "iphone", color: blueColor, accentColor: .blue, valueColor: .white),
            CardData(id: .caffeineRiver, title: "Caffeine River", value: formatLargeNumber(stats.caffeineRiverLiters) + "L", subtitle: "of coffee", chartData: ascendingData, icon: "cup.and.saucer", color: redColor, accentColor: .red, valueColor: Color(red: 1.0, green: 0.6, blue: 0.6))
        ]

        let hasBirthContext = profile.birthTimeTimestamp != nil || !profile.birthCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if hasBirthContext {
            let city = profile.birthCity.trimmingCharacters(in: .whitespacesAndNewlines)
            let subtitle = city.isEmpty ? "estimated since birth" : "estimated in \(city)"
            cards.append(CardData(id: .sunsets, title: "Sunsets", value: formatLargeNumber(stats.totalDaysAlive), subtitle: subtitle, chartData: ascendingData, icon: "sunset", color: yellowColor, accentColor: .orange, valueColor: .yellow))
        }

        if let passionStartDate = profile.passionStartDate {
            let passionDays = days(from: passionStartDate, to: currentDate)
            let eraPercentage = stats.totalDaysAlive > 0 ? (Double(passionDays) / Double(stats.totalDaysAlive)) * 100 : 0
            let passionTitle = profile.passionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let passionSubtitle = passionTitle.isEmpty ? "of this era" : "as \(passionTitle)"
            let estimatedHours = max(0, Int((Double(passionDays) / 7.0) * profile.passionHoursPerWeek))

            cards.append(CardData(id: .passionEra, title: "Era Share", value: formatDouble(eraPercentage) + "%", subtitle: passionSubtitle, chartData: ascendingData, icon: "sparkles", color: greenColor, accentColor: .green, valueColor: .white))
            cards.append(CardData(id: .masteryHours, title: "Mastery", value: formatLargeNumber(estimatedHours) + "h", subtitle: "toward 10,000 hours", chartData: ascendingData, icon: "target", color: greenColor, accentColor: .green, valueColor: .white))
        }

        if let metDate = profile.favoritePersonMetDate {
            let sharedDays = days(from: metDate, to: currentDate)
            let sharedSeconds = max(0, Int(currentDate.timeIntervalSince(metDate)))
            let sharedHeartbeats = Int((Double(sharedSeconds) / 60.0) * 70.0 * 2.0)
            let personName = profile.favoritePersonName.trimmingCharacters(in: .whitespacesAndNewlines)
            let personSubtitle = personName.isEmpty ? "together on Earth" : "with \(personName)"

            cards.append(CardData(id: .sharedDays, title: "Shared Days", value: formatLargeNumber(sharedDays), subtitle: personSubtitle, chartData: ascendingData, icon: "person.2.fill", color: tealColor, accentColor: .cyan, valueColor: .white))
            cards.append(CardData(id: .sharedHeartbeats, title: "Shared Beats", value: formatMillions(sharedHeartbeats), subtitle: "combined since meeting", chartData: ascendingData, icon: "heart.text.square", color: tealColor, accentColor: .cyan, valueColor: .white))
        }

        if let heightCentimeters = profile.heightCentimeters, heightCentimeters > 0 {
            let nailGrowthMeters = Double(stats.totalDaysAlive) * 0.0001 * 20.0
            let bodyHeights = nailGrowthMeters / (heightCentimeters / 100.0)
            cards.append(CardData(id: .nailGrowth, title: "Nail Growth", value: formatDouble(nailGrowthMeters) + "m", subtitle: "\(formatDouble(bodyHeights)) body heights", chartData: ascendingData, icon: "hand.raised", color: redColor, accentColor: .red, valueColor: Color(red: 1.0, green: 0.6, blue: 0.6)))
        }

        if let readingSpeed = profile.readingSpeed {
            let readingStartDate = Calendar.current.date(byAdding: .year, value: 6, to: profile.dateOfBirth) ?? profile.dateOfBirth
            let readingDays = days(from: readingStartDate, to: currentDate)
            let estimatedWords = readingDays * readingSpeed.wordsPerMinute * 20
            cards.append(CardData(id: .wordsRead, title: "Words Read", value: formatMillions(estimatedWords), subtitle: "\(readingSpeed.title.lowercased()) reading pace", chartData: ascendingData, icon: "book.pages", color: blueColor, accentColor: .blue, valueColor: .white))
        }

        return cards
    }

    private func days(from startDate: Date, to endDate: Date) -> Int {
        max(0, Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0)
    }
}

// MARK: - Subcomponents

struct GridCardView: View {
    let card: CardData
    var animation: Namespace.ID
    var isSelected: Bool

    private let supportingTextColor = Color.white.opacity(0.65)
    
    var body: some View {
        ZStack {
            if isSelected {
                Color.clear
                    .frame(height: card.isFullWidth ? 140 : 160)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(card.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(supportingTextColor)
                            .matchedGeometryEffect(id: "title\(card.id)", in: animation)
                        Spacer()
                        Image(systemName: card.icon)
                            .foregroundColor(card.accentColor)
                            .opacity(0.8)
                            .matchedGeometryEffect(id: "icon\(card.id)", in: animation)
                    }
                    
                    Spacer()
                    
                    Text(card.value)
                        .font(.system(size: card.isFullWidth ? 36 : 28, weight: .bold))
                        .foregroundColor(card.valueColor)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .matchedGeometryEffect(id: "value\(card.id)", in: animation)
                    
                    Text(card.subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(supportingTextColor)
                        .matchedGeometryEffect(id: "subtitle\(card.id)", in: animation)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: card.isFullWidth ? 140 : 160)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(card.color)
                        .matchedGeometryEffect(id: "bg\(card.id)", in: animation)
                )
            }
        }
    }
}

struct ExpandedCardView: View {
    let card: CardData
    var animation: Namespace.ID
    var onClose: () -> Void
    
    @State private var showDetails = false

    private let supportingTextColor = Color.white.opacity(0.65)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(card.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(supportingTextColor)
                    .matchedGeometryEffect(id: "title\(card.id)", in: animation)
                Spacer()
                Image(systemName: card.icon)
                    .foregroundColor(card.accentColor)
                    .opacity(0.8)
                    .matchedGeometryEffect(id: "icon\(card.id)", in: animation)
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(supportingTextColor)
                }
                .padding(.leading, 8)
            }
            
            Text(card.value)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(card.valueColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .matchedGeometryEffect(id: "value\(card.id)", in: animation)
            
            Text(card.subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(supportingTextColor)
                .matchedGeometryEffect(id: "subtitle\(card.id)", in: animation)
            
            if showDetails {
                VStack(spacing: 24) {
                    Divider().background(Color.white.opacity(0.2)).padding(.vertical, 8)
                    
                    // Simple Animated Bar Chart
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(0..<card.chartData.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 20, height: 60 * card.chartData[index])
                                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.05), value: showDetails)
                        }
                    }
                    .frame(height: 70)
                    .padding(.bottom, 8)
                    
                    Button(action: {
                        ShareHelper.shareMilestone(title: card.title, subtitle: "Vitalz Checkpoint", statValue: card.value)
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Milestone")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(card.color.opacity(0.95))
                .matchedGeometryEffect(id: "bg\(card.id)", in: animation)
                .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 20)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                showDetails = true
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(ProfileStore())
}

#Preview {
    DashboardView()
        .environmentObject(ProfileStore())
}
