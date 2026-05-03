import SwiftUI

public struct CardData: Identifiable {
    public enum ID: String, Hashable {
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

    public let id: ID
    public let title: LocalizedStringResource
    public let value: LocalizedStringResource
    public let subtitle: LocalizedStringResource
    public let chartData: [CGFloat]
    public let icon: String
    public let color: Color
    public let accentColor: Color
    public let valueColor: Color
    public var isFullWidth: Bool = false
    
    public init(id: ID, title: LocalizedStringResource, value: LocalizedStringResource, subtitle: LocalizedStringResource, chartData: [CGFloat], icon: String, color: Color, accentColor: Color, valueColor: Color, isFullWidth: Bool = false) {
        self.id = id
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.chartData = chartData
        self.icon = icon
        self.color = color
        self.accentColor = accentColor
        self.valueColor = valueColor
        self.isFullWidth = isFullWidth
    }
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
    @AppStorage("useMetricUnits") private var useMetricUnits: Bool = true
    @AppStorage("cardOrder") private var cardOrder: String = ""
    @AppStorage("wallpaperTheme") private var wallpaperThemeRaw: String = WallpaperTheme.standardLight.rawValue
    @AppStorage("averageScreenTime") private var averageScreenTime: Double = 0.0
    @AppStorage("dailyCoffeeCups") private var dailyCoffeeCups: Int = 0
    
    @State private var currentDate = Date()
    @State private var stats: LifeStats? = nil
    @State private var showingSettings = false
    @State private var showingRearrange = false
    @State private var draggedItemID: String? = nil
    
    @Namespace private var animation
    @State private var selectedCardID: CardData.ID? = nil
    
    private var activeWallpaper: WallpaperTheme {
        WallpaperTheme(rawValue: wallpaperThemeRaw) ?? .standardLight
    }
    
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
                    // Profile Header — centered, tappable for Settings
                    VStack(spacing: 10) {
                        Button {
                            showingSettings = true
                        } label: {
                            ProfileAvatarView(
                                imageData: profileStore.selectedProfile.imageData,
                                size: 70
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.vitalzAccent.opacity(0.3), lineWidth: 2)
                                    .frame(width: 76, height: 76)
                            )
                        }
                        .buttonStyle(.plain)

                        VStack(spacing: 4) {
                            Text(userName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(activeWallpaper == .standardLight || activeWallpaper == .standardDark ? .vitalzText : activeWallpaper.textColor)

                            Text(Date(), style: .date)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(activeWallpaper == .standardLight || activeWallpaper == .standardDark ? .vitalzSecondaryText : activeWallpaper.textColor.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .background(
                        Group {
                            if activeWallpaper != .standardLight && activeWallpaper != .standardDark {
                                activeWallpaper.backgroundView
                                    .ignoresSafeArea(edges: .top)
                            }
                        }
                    )
                    
                    if let stats = stats {
                        let elements = generateElements(from: stats, profile: profileStore.selectedProfile)
                        let rows = chunkElements(elements)
                        
                        VStack(spacing: 16) {
                            ForEach(rows) { row in
                                switch row {
                                case .fullWidth(let element):
                                    renderElement(element, percentageLived: stats.percentageOf80YearLifeExpectancy)
                                case .split(let e1, let e2):
                                    HStack(spacing: 16) {
                                        renderElement(e1, percentageLived: stats.percentageOf80YearLifeExpectancy)
                                        if let e2 = e2 {
                                            renderElement(e2, percentageLived: stats.percentageOf80YearLifeExpectancy)
                                        } else {
                                            Color.clear
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Scroll Anchor Logo
                        Image("VitalzLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 16)
                            .opacity(0.3)
                            .padding(.top, 60)
                            .padding(.bottom, 100)
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
        .sheet(isPresented: $showingRearrange) {
            RearrangeCardsView()
        }
        .onAppear { 
            updateStats(for: currentDate) 
            if cardOrder.isEmpty {
                cardOrder = defaultCardOrder.joined(separator: ",")
            }
        }
        .onChange(of: profileStore.selectedProfileID) { _ in updateStats(for: currentDate) }
        .onChange(of: profileStore.selectedProfile.dateOfBirthTimestamp) { _ in updateStats(for: currentDate) }
        .onReceive(timer) { input in
            currentDate = input
            updateStats(for: input)
        }
    }
    
    private var activeCardIDs: [CardData.ID] {
        var ids: [CardData.ID] = []
        if showSecondsAlive { ids.append(.secondsAlive) }
        if showHeartbeats { ids.append(.heartbeats) }
        if showBreathsTaken { ids.append(.breathsTaken) }
        if showTimesBlinked { ids.append(.timesBlinked) }
        if showHairGrowth { ids.append(.hairGrowth) }
        if showSpaceTraveler { ids.append(.spaceTraveler) }
        
        ids.append(contentsOf: [
            .fullMoons, .jupiterAge, .sleep,
            .sunsets, .passionEra, .masteryHours, .sharedDays,
            .sharedHeartbeats, .nailGrowth, .wordsRead
        ])
        
        if averageScreenTime > 0 { ids.append(.phoneVoid) }
        if dailyCoffeeCups > 0 { ids.append(.caffeineRiver) }
        
        return ids
    }
    
    private let defaultCardOrder = [
        "secondsAlive", "heartbeats", "breathsTaken", "timesBlinked", "hairGrowth",
        "adSpace", "lifeLoading", "spaceTraveler", "fullMoons", "jupiterAge", "sleep",
        "phoneVoid", "caffeineRiver", "sunsets", "passionEra", "masteryHours",
        "sharedDays", "sharedHeartbeats", "nailGrowth", "wordsRead"
    ]
    
    private func generateElements(from stats: LifeStats, profile: VitalzProfile) -> [DashboardElement] {
        let allCards = generateCards(from: stats, profile: profile)
        let activeIDs = activeCardIDs
        
        var elements: [DashboardElement] = []
        
        let orderString = cardOrder.isEmpty ? defaultCardOrder.joined(separator: ",") : cardOrder
        let order = orderString.components(separatedBy: ",")
        
        for idString in order {
            if idString == "adSpace" {
                elements.append(.adSpace)
                continue
            }
            if idString == "lifeLoading" {
                elements.append(.lifeLoading)
                continue
            }
            if let cardID = CardData.ID(rawValue: idString),
               activeIDs.contains(cardID),
               let card = allCards.first(where: { $0.id == cardID }) {
                elements.append(.card(card))
            }
        }
        
        return elements
    }
    
    private func chunkElements(_ elements: [DashboardElement]) -> [DashboardRow] {
        var rows: [DashboardRow] = []
        var pendingSplit: DashboardElement? = nil
        
        for element in elements {
            if element.isFullWidth {
                if let p = pendingSplit {
                    rows.append(.split(p, nil))
                    pendingSplit = nil
                }
                rows.append(.fullWidth(element))
            } else {
                if let p = pendingSplit {
                    rows.append(.split(p, element))
                    pendingSplit = nil
                } else {
                    pendingSplit = element
                }
            }
        }
        
        if let p = pendingSplit {
            rows.append(.split(p, nil))
        }
        
        return rows
    }
    
    @ViewBuilder
    private func renderElement(_ element: DashboardElement, percentageLived: Double) -> some View {
        Group {
            switch element {
            case .card(let card):
                if card.id == .passionEra && card.isFullWidth, let stats {
                    Button(action: { selectCard(card) }) {
                        EraShareGridCardView(
                            card: card,
                            hobbies: profileStore.selectedProfile.hobbies.filter { $0.isEnabled },
                            stats: stats,
                            animation: animation,
                            isSelected: selectedCardID == card.id
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: { selectCard(card) }) {
                        GridCardView(card: card, animation: animation, isSelected: selectedCardID == card.id)
                    }
                    .buttonStyle(.plain)
                }
                
            case .adSpace:
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
                
            case .lifeLoading:
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
                        Text("\(percentageLived, format: .number.precision(.fractionLength(1)))%")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.vitalzText)
                    }
                }
                .padding(24)
                .background(Color.vitalzCard)
                .cornerRadius(24)
            }
        }
        .onDrag {
            self.draggedItemID = element.id
            return NSItemProvider(object: element.id as NSString)
        }
        .onDrop(of: [.text], delegate: DashboardDropDelegate(
            itemID: element.id,
            cardOrder: $cardOrder,
            draggedItemID: $draggedItemID,
            defaultCardOrder: defaultCardOrder
        ))
    }

    private func selectCard(_ card: CardData) {
        HapticEngine.playTick()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            selectedCardID = card.id
        }
    }
    
    private func closeCard() {
        HapticEngine.playTick()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            selectedCardID = nil
        }
    }
    
    private func updateStats(for date: Date) {
        let math = LifeMath(
            dateOfBirth: profileStore.selectedProfile.effectiveDateOfBirth,
            averagePhoneHoursPerDay: averageScreenTime,
            dailyCoffeeCups: dailyCoffeeCups
        )
        self.stats = math.calculateStats(upTo: date)
    }

    private var userName: String {
        profileStore.selectedProfile.name
    }
    
    private func cardColor(_ id: CardData.ID) -> Color { id.category.cardColor }
    private func cardAccent(_ id: CardData.ID) -> Color { id.category.accentColor }
    private func cardValue(_ id: CardData.ID) -> Color { id.category.valueColor }
    
    private func generateCards(from stats: LifeStats, profile: VitalzProfile) -> [CardData] {
        let ascendingData: [CGFloat] = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
        
        var cards = [
            CardData(id: .secondsAlive, title: "Seconds Alive", value: "\(stats.totalSecondsAlive, format: .number)", subtitle: "and counting...", chartData: ascendingData, icon: "stopwatch", color: cardColor(.secondsAlive), accentColor: cardAccent(.secondsAlive), valueColor: cardValue(.secondsAlive), isFullWidth: true),
            CardData(id: .heartbeats, title: "Heartbeats", value: "\(stats.estimatedTotalHeartbeats, format: .number.notation(.compactName))", subtitle: "@ 70 bpm", chartData: ascendingData, icon: "heart", color: cardColor(.heartbeats), accentColor: cardAccent(.heartbeats), valueColor: cardValue(.heartbeats)),
            CardData(id: .breathsTaken, title: "Breaths Taken", value: "\(stats.estimatedBreathsTaken, format: .number.notation(.compactName))", subtitle: "@ 16/min", chartData: ascendingData, icon: "wind", color: cardColor(.breathsTaken), accentColor: cardAccent(.breathsTaken), valueColor: cardValue(.breathsTaken)),
            CardData(id: .timesBlinked, title: "Times Blinked", value: "\(stats.estimatedBlinks, format: .number.notation(.compactName))", subtitle: "while awake", chartData: ascendingData, icon: "eye", color: cardColor(.timesBlinked), accentColor: cardAccent(.timesBlinked), valueColor: cardValue(.timesBlinked)),
            CardData(id: .hairGrowth, title: "Hair Growth", value: formattedLength(meters: stats.hairGrowthMeters), subtitle: "of hair grown", chartData: ascendingData, icon: "scissors", color: cardColor(.hairGrowth), accentColor: cardAccent(.hairGrowth), valueColor: cardValue(.hairGrowth)),
            CardData(id: .spaceTraveler, title: "Space Traveler", value: formattedDistance(kilometers: stats.distanceTraveledSpaceKm), subtitle: useMetricUnits ? "km around Sun" : "mi around Sun", chartData: ascendingData, icon: "location.north.fill", color: cardColor(.spaceTraveler), accentColor: cardAccent(.spaceTraveler), valueColor: cardValue(.spaceTraveler)),
            CardData(id: .fullMoons, title: "Full Moons", value: "\(stats.fullMoonsWitnessed, format: .number)", subtitle: "witnessed", chartData: ascendingData, icon: "moon", color: cardColor(.fullMoons), accentColor: cardAccent(.fullMoons), valueColor: cardValue(.fullMoons)),
            CardData(id: .jupiterAge, title: "Jupiter Age", value: "\(stats.jupiterAge, format: .number.precision(.fractionLength(2)))", subtitle: "years on Jupiter", chartData: ascendingData, icon: "globe", color: cardColor(.jupiterAge), accentColor: cardAccent(.jupiterAge), valueColor: cardValue(.jupiterAge)),
            CardData(id: .sleep, title: "Sleep", value: "\(stats.estimatedHoursSlept / 24.0 / 365.25, format: .number.precision(.fractionLength(1))) yrs", subtitle: "spent dreaming", chartData: ascendingData, icon: "moon.zzz", color: cardColor(.sleep), accentColor: cardAccent(.sleep), valueColor: cardValue(.sleep)),
            CardData(id: .phoneVoid, title: "Phone Void", value: "\(stats.phoneVoidYears, format: .number.precision(.fractionLength(1))) yrs", subtitle: "lost to screens", chartData: ascendingData, icon: "iphone", color: cardColor(.phoneVoid), accentColor: cardAccent(.phoneVoid), valueColor: cardValue(.phoneVoid)),
            CardData(id: .caffeineRiver, title: "Caffeine River", value: "\(stats.caffeineRiverLiters, format: .number)L", subtitle: "of coffee", chartData: ascendingData, icon: "cup.and.saucer", color: cardColor(.caffeineRiver), accentColor: cardAccent(.caffeineRiver), valueColor: cardValue(.caffeineRiver))
        ]

        let hasBirthContext = profile.birthTimeTimestamp != nil || !profile.birthCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if hasBirthContext {
            let city = profile.birthCity.trimmingCharacters(in: .whitespacesAndNewlines)
            let subtitle: LocalizedStringResource = city.isEmpty ? "estimated since birth" : "estimated in \(city)"
            cards.append(CardData(id: .sunsets, title: "Sunsets", value: "\(stats.totalDaysAlive, format: .number)", subtitle: subtitle, chartData: ascendingData, icon: "sunset", color: cardColor(.sunsets), accentColor: cardAccent(.sunsets), valueColor: cardValue(.sunsets)))
        }

        // Multi-hobby Era Share — uses the first enabled hobby for the card value
        let enabledHobbies = profile.hobbies.filter { $0.isEnabled }
        if let primary = enabledHobbies.first {
            let passionDays = days(from: primary.startDate, to: currentDate)
            let eraPercentage = stats.totalDaysAlive > 0 ? (Double(passionDays) / Double(stats.totalDaysAlive)) * 100 : 0
            let trimmedTitle = primary.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let countSuffix = enabledHobbies.count > 1 ? " (+\(enabledHobbies.count - 1))" : ""
            let passionSubtitle: LocalizedStringResource = trimmedTitle.isEmpty ? "of this era" : "as \(trimmedTitle)\(countSuffix)"
            let estimatedHours = max(0, Int((Double(passionDays) / 7.0) * primary.hoursPerWeek))

            cards.append(CardData(id: .passionEra, title: "Era Share", value: "\(eraPercentage, format: .number.precision(.fractionLength(1)))%", subtitle: passionSubtitle, chartData: ascendingData, icon: "sparkles", color: cardColor(.passionEra), accentColor: cardAccent(.passionEra), valueColor: cardValue(.passionEra), isFullWidth: enabledHobbies.count > 1))
            cards.append(CardData(id: .masteryHours, title: "Mastery", value: "\(estimatedHours, format: .number)h", subtitle: "toward 10,000 hours", chartData: ascendingData, icon: "target", color: cardColor(.masteryHours), accentColor: cardAccent(.masteryHours), valueColor: cardValue(.masteryHours)))
        }

        if let person = profile.trackedPeople.first {
            let sharedDays = days(from: person.metDate, to: currentDate)
            let sharedSeconds = max(0, Int(currentDate.timeIntervalSince(person.metDate)))
            let sharedHeartbeats = Int((Double(sharedSeconds) / 60.0) * 70.0 * 2.0)
            let personName = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let personSubtitle: LocalizedStringResource = personName.isEmpty ? "together on Earth" : "with \(personName)"

            cards.append(CardData(id: .sharedDays, title: "Shared Days", value: "\(sharedDays, format: .number)", subtitle: personSubtitle, chartData: ascendingData, icon: "person.2.fill", color: cardColor(.sharedDays), accentColor: cardAccent(.sharedDays), valueColor: cardValue(.sharedDays)))
            cards.append(CardData(id: .sharedHeartbeats, title: "Shared Beats", value: "\(sharedHeartbeats, format: .number.notation(.compactName))", subtitle: "combined since meeting", chartData: ascendingData, icon: "heart.text.square", color: cardColor(.sharedHeartbeats), accentColor: cardAccent(.sharedHeartbeats), valueColor: cardValue(.sharedHeartbeats)))
        }

        if let heightCentimeters = profile.heightCentimeters, heightCentimeters > 0 {
            let nailGrowthMeters = Double(stats.totalDaysAlive) * 0.0001 * 20.0
            let bodyHeights = nailGrowthMeters / (heightCentimeters / 100.0)
            cards.append(CardData(id: .nailGrowth, title: "Nail Growth", value: formattedLength(meters: nailGrowthMeters), subtitle: "\(bodyHeights, format: .number.precision(.fractionLength(1))) body heights", chartData: ascendingData, icon: "hand.raised", color: cardColor(.nailGrowth), accentColor: cardAccent(.nailGrowth), valueColor: cardValue(.nailGrowth)))
        }

        if let readingSpeed = profile.readingSpeed {
            let readingStartDate = Calendar.current.date(byAdding: .year, value: 6, to: profile.dateOfBirth) ?? profile.dateOfBirth
            let readingDays = days(from: readingStartDate, to: currentDate)
            let estimatedWords = readingDays * readingSpeed.wordsPerMinute * 20
            cards.append(CardData(id: .wordsRead, title: "Words Read", value: "\(estimatedWords, format: .number.notation(.compactName))", subtitle: "\(readingSpeed.title.lowercased()) reading pace", chartData: ascendingData, icon: "book.pages", color: cardColor(.wordsRead), accentColor: cardAccent(.wordsRead), valueColor: cardValue(.wordsRead)))
        }

        return cards
    }

    private func days(from startDate: Date, to endDate: Date) -> Int {
        max(0, Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0)
    }

    private func formattedDistance(kilometers: Int) -> LocalizedStringResource {
        if useMetricUnits {
            return "\(kilometers, format: .number.notation(.compactName))"
        }

        let miles = Double(kilometers) * 0.621371
        return "\(miles, format: .number.notation(.compactName))"
    }

    private func formattedLength(meters: Double) -> LocalizedStringResource {
        if useMetricUnits {
            return "\(meters, format: .number.precision(.fractionLength(1)))m"
        }

        return "\(meters * 3.28084, format: .number.precision(.fractionLength(1)))ft"
    }
}

// MARK: - Drag & Drop Delegate

struct DashboardDropDelegate: DropDelegate {
    let itemID: String
    @Binding var cardOrder: String
    @Binding var draggedItemID: String?
    let defaultCardOrder: [String]

    func dropEntered(info: DropInfo) {
        guard let dragged = draggedItemID,
              dragged != itemID else { return }
        
        let currentOrder = cardOrder.isEmpty ? defaultCardOrder : cardOrder.components(separatedBy: ",")
        var items = currentOrder
        
        guard let from = items.firstIndex(of: dragged),
              let to = items.firstIndex(of: itemID) else { return }
        
        if from != to {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                let moved = items.remove(at: from)
                items.insert(moved, at: to)
                cardOrder = items.joined(separator: ",")
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        self.draggedItemID = nil
        return true
    }
}

// MARK: - Layout Models

enum DashboardElement: Identifiable {
    case card(CardData)
    case adSpace
    case lifeLoading
    
    var id: String {
        switch self {
        case .card(let c): return c.id.rawValue
        case .adSpace: return "adSpace"
        case .lifeLoading: return "lifeLoading"
        }
    }
    
    var isFullWidth: Bool {
        switch self {
        case .card(let c): return c.isFullWidth
        case .adSpace, .lifeLoading: return true
        }
    }
}

enum DashboardRow: Identifiable {
    case fullWidth(DashboardElement)
    case split(DashboardElement, DashboardElement?)
    
    var id: String {
        switch self {
        case .fullWidth(let e): return e.id
        case .split(let e1, let e2): return e1.id + (e2?.id ?? "")
        }
    }
}

// MARK: - Subcomponents

struct GridCardView: View {
    let card: CardData
    var animation: Namespace.ID
    var isSelected: Bool

    private let supportingTextColor = Color.vitalzSecondaryText
    
    var body: some View {
        ZStack {
            if isSelected {
                Color.clear
                    .frame(minHeight: card.isFullWidth ? 140 : 160)
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
                .frame(height: card.isFullWidth ? nil : 160)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(card.color)
                        .matchedGeometryEffect(id: "bg\(card.id)", in: animation)
                )
            }
        }
    }
}

struct EraShareGridCardView: View {
    let card: CardData
    let hobbies: [Hobby]
    let stats: LifeStats
    var animation: Namespace.ID
    var isSelected: Bool

    var body: some View {
        ZStack {
            if isSelected {
                Color.clear.frame(minHeight: 180)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Text(card.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.vitalzSecondaryText)
                            .matchedGeometryEffect(id: "title\(card.id)", in: animation)
                        Spacer()
                        Image(systemName: card.icon)
                            .foregroundColor(card.accentColor)
                            .opacity(0.8)
                            .matchedGeometryEffect(id: "icon\(card.id)", in: animation)
                    }

                    // Hobby List
                    VStack(spacing: 16) {
                        ForEach(hobbies) { hobby in
                            let days = max(0, Calendar.current.dateComponents([.day], from: hobby.startDate, to: Date()).day ?? 0)
                            let percentage = stats.totalDaysAlive > 0 ? (Double(days) / Double(stats.totalDaysAlive)) * 100 : 0
                            
                            HStack(spacing: 12) {
                                Image(systemName: hobby.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(card.accentColor)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(hobby.title.isEmpty ? "Hobby" : hobby.title)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(card.valueColor)
                                        .lineLimit(1)
                                    
                                    Text("\(String(format: "%.1f", percentage))% of your life")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.vitalzSecondaryText)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(days)")
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundColor(card.accentColor)
                                    Text("days")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundColor(.vitalzSecondaryText)
                                        .textCase(.uppercase)
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
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
    @State private var showShareSheet = false

    private let supportingTextColor = Color.vitalzSecondaryText
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
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
                
                // Big Value
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
                    let detail = card.id.detailContent
                    
                    VStack(spacing: 20) {
                        Divider().background(Color.vitalzDivider).padding(.vertical, 4)
                        
                        // Unique Visualization
                        HStack {
                            Spacer()
                            CardVisualization(cardID: card.id, card: card)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                        // Description
                        Text(detail.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.vitalzSecondaryText)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Comparisons
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(detail.comparisons, id: \.self) { comparison in
                                Text(comparison)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.vitalzText.opacity(0.8))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.vitalzSecondaryText.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                        
                        // Fun Fact
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 13))
                                Text("Fun Fact")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.yellow.opacity(0.9))
                                    .textCase(.uppercase)
                                    .kerning(1)
                            }
                            
                            Text(detail.funFact)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.vitalzText.opacity(0.9))
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .background(Color.yellow.opacity(0.08))
                        .cornerRadius(14)
                        
                        // Share Button
                        Button(action: {
                            showShareSheet = true
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
                                    .fill(Color.vitalzAccent)
                            )
                        }
                        .sheet(isPresented: $showShareSheet) {
                            ShareActionSheet(
                                milestoneTitle: card.title,
                                subtitle: "Vitalz Checkpoint",
                                statValue: card.value
                            )
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(24)
        }
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(card.color.opacity(0.95))
                .matchedGeometryEffect(id: "bg\(card.id)", in: animation)
                .shadow(color: .vitalzShadow, radius: 30, x: 0, y: 20)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.25)) {
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
