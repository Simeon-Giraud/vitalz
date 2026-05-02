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
    public let title: String
    public let value: String
    public let subtitle: String
    public let chartData: [CGFloat]
    public let icon: String
    public let color: Color
    public let accentColor: Color
    public let valueColor: Color
    public var isFullWidth: Bool = false
    
    public init(id: ID, title: String, value: String, subtitle: String, chartData: [CGFloat], icon: String, color: Color, accentColor: Color, valueColor: Color, isFullWidth: Bool = false) {
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
    @AppStorage("averageScreenTime") private var averageScreenTime: Double = 0.0
    @AppStorage("dailyCoffeeCups") private var dailyCoffeeCups: Int = 0
    
    @State private var currentDate = Date()
    @State private var stats: LifeStats? = nil
    @State private var showingSettings = false
    @State private var showingRearrange = false
    @State private var draggedItemID: String? = nil
    
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
                        
                        VitalzGlassButton(shape: .circle, isProminent: false, action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20))
                                .foregroundColor(.vitalzText)
                                .padding(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
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
                Button(action: { selectCard(card) }) {
                    GridCardView(card: card, animation: animation, isSelected: selectedCardID == card.id)
                }
                .buttonStyle(.plain)
                
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
                        Text(String(format: "%.1f%%", percentageLived))
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
    
    private func cardColor(_ id: CardData.ID) -> Color { id.category.cardColor }
    private func cardAccent(_ id: CardData.ID) -> Color { id.category.accentColor }
    private func cardValue(_ id: CardData.ID) -> Color { id.category.valueColor }
    
    private func generateCards(from stats: LifeStats, profile: VitalzProfile) -> [CardData] {
        let ascendingData: [CGFloat] = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
        
        var cards = [
            CardData(id: .secondsAlive, title: "Seconds Alive", value: formatLargeNumber(stats.totalSecondsAlive), subtitle: "and counting...", chartData: ascendingData, icon: "stopwatch", color: cardColor(.secondsAlive), accentColor: cardAccent(.secondsAlive), valueColor: cardValue(.secondsAlive), isFullWidth: true),
            CardData(id: .heartbeats, title: "Heartbeats", value: formatMillions(stats.estimatedTotalHeartbeats), subtitle: "@ 70 bpm", chartData: ascendingData, icon: "heart", color: cardColor(.heartbeats), accentColor: cardAccent(.heartbeats), valueColor: cardValue(.heartbeats)),
            CardData(id: .breathsTaken, title: "Breaths Taken", value: formatMillions(stats.estimatedBreathsTaken), subtitle: "@ 16/min", chartData: ascendingData, icon: "wind", color: cardColor(.breathsTaken), accentColor: cardAccent(.breathsTaken), valueColor: cardValue(.breathsTaken)),
            CardData(id: .timesBlinked, title: "Times Blinked", value: formatMillions(stats.estimatedBlinks), subtitle: "while awake", chartData: ascendingData, icon: "eye", color: cardColor(.timesBlinked), accentColor: cardAccent(.timesBlinked), valueColor: cardValue(.timesBlinked)),
            CardData(id: .hairGrowth, title: "Hair Growth", value: formattedLength(meters: stats.hairGrowthMeters), subtitle: "of hair grown", chartData: ascendingData, icon: "scissors", color: cardColor(.hairGrowth), accentColor: cardAccent(.hairGrowth), valueColor: cardValue(.hairGrowth)),
            CardData(id: .spaceTraveler, title: "Space Traveler", value: formattedDistance(kilometers: stats.distanceTraveledSpaceKm), subtitle: useMetricUnits ? "km around Sun" : "mi around Sun", chartData: ascendingData, icon: "location.north.fill", color: cardColor(.spaceTraveler), accentColor: cardAccent(.spaceTraveler), valueColor: cardValue(.spaceTraveler)),
            CardData(id: .fullMoons, title: "Full Moons", value: formatLargeNumber(stats.fullMoonsWitnessed), subtitle: "witnessed", chartData: ascendingData, icon: "moon", color: cardColor(.fullMoons), accentColor: cardAccent(.fullMoons), valueColor: cardValue(.fullMoons)),
            CardData(id: .jupiterAge, title: "Jupiter Age", value: formatDouble(stats.jupiterAge, decimals: 2), subtitle: "years on Jupiter", chartData: ascendingData, icon: "globe", color: cardColor(.jupiterAge), accentColor: cardAccent(.jupiterAge), valueColor: cardValue(.jupiterAge)),
            CardData(id: .sleep, title: "Sleep", value: formatDouble(stats.estimatedHoursSlept / 24.0 / 365.25) + " yrs", subtitle: "spent dreaming", chartData: ascendingData, icon: "moon.zzz", color: cardColor(.sleep), accentColor: cardAccent(.sleep), valueColor: cardValue(.sleep)),
            CardData(id: .phoneVoid, title: "Phone Void", value: formatDouble(stats.phoneVoidYears) + " yrs", subtitle: "lost to screens", chartData: ascendingData, icon: "iphone", color: cardColor(.phoneVoid), accentColor: cardAccent(.phoneVoid), valueColor: cardValue(.phoneVoid)),
            CardData(id: .caffeineRiver, title: "Caffeine River", value: formatLargeNumber(stats.caffeineRiverLiters) + "L", subtitle: "of coffee", chartData: ascendingData, icon: "cup.and.saucer", color: cardColor(.caffeineRiver), accentColor: cardAccent(.caffeineRiver), valueColor: cardValue(.caffeineRiver))
        ]

        let hasBirthContext = profile.birthTimeTimestamp != nil || !profile.birthCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if hasBirthContext {
            let city = profile.birthCity.trimmingCharacters(in: .whitespacesAndNewlines)
            let subtitle = city.isEmpty ? "estimated since birth" : "estimated in \(city)"
            cards.append(CardData(id: .sunsets, title: "Sunsets", value: formatLargeNumber(stats.totalDaysAlive), subtitle: subtitle, chartData: ascendingData, icon: "sunset", color: cardColor(.sunsets), accentColor: cardAccent(.sunsets), valueColor: cardValue(.sunsets)))
        }

        if let passionStartDate = profile.passionStartDate {
            let passionDays = days(from: passionStartDate, to: currentDate)
            let eraPercentage = stats.totalDaysAlive > 0 ? (Double(passionDays) / Double(stats.totalDaysAlive)) * 100 : 0
            let passionTitle = profile.passionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let passionSubtitle = passionTitle.isEmpty ? "of this era" : "as \(passionTitle)"
            let estimatedHours = max(0, Int((Double(passionDays) / 7.0) * profile.passionHoursPerWeek))

            cards.append(CardData(id: .passionEra, title: "Era Share", value: formatDouble(eraPercentage) + "%", subtitle: passionSubtitle, chartData: ascendingData, icon: "sparkles", color: cardColor(.passionEra), accentColor: cardAccent(.passionEra), valueColor: cardValue(.passionEra)))
            cards.append(CardData(id: .masteryHours, title: "Mastery", value: formatLargeNumber(estimatedHours) + "h", subtitle: "toward 10,000 hours", chartData: ascendingData, icon: "target", color: cardColor(.masteryHours), accentColor: cardAccent(.masteryHours), valueColor: cardValue(.masteryHours)))
        }

        if let metDate = profile.favoritePersonMetDate {
            let sharedDays = days(from: metDate, to: currentDate)
            let sharedSeconds = max(0, Int(currentDate.timeIntervalSince(metDate)))
            let sharedHeartbeats = Int((Double(sharedSeconds) / 60.0) * 70.0 * 2.0)
            let personName = profile.favoritePersonName.trimmingCharacters(in: .whitespacesAndNewlines)
            let personSubtitle = personName.isEmpty ? "together on Earth" : "with \(personName)"

            cards.append(CardData(id: .sharedDays, title: "Shared Days", value: formatLargeNumber(sharedDays), subtitle: personSubtitle, chartData: ascendingData, icon: "person.2.fill", color: cardColor(.sharedDays), accentColor: cardAccent(.sharedDays), valueColor: cardValue(.sharedDays)))
            cards.append(CardData(id: .sharedHeartbeats, title: "Shared Beats", value: formatMillions(sharedHeartbeats), subtitle: "combined since meeting", chartData: ascendingData, icon: "heart.text.square", color: cardColor(.sharedHeartbeats), accentColor: cardAccent(.sharedHeartbeats), valueColor: cardValue(.sharedHeartbeats)))
        }

        if let heightCentimeters = profile.heightCentimeters, heightCentimeters > 0 {
            let nailGrowthMeters = Double(stats.totalDaysAlive) * 0.0001 * 20.0
            let bodyHeights = nailGrowthMeters / (heightCentimeters / 100.0)
            cards.append(CardData(id: .nailGrowth, title: "Nail Growth", value: formattedLength(meters: nailGrowthMeters), subtitle: "\(formatDouble(bodyHeights)) body heights", chartData: ascendingData, icon: "hand.raised", color: cardColor(.nailGrowth), accentColor: cardAccent(.nailGrowth), valueColor: cardValue(.nailGrowth)))
        }

        if let readingSpeed = profile.readingSpeed {
            let readingStartDate = Calendar.current.date(byAdding: .year, value: 6, to: profile.dateOfBirth) ?? profile.dateOfBirth
            let readingDays = days(from: readingStartDate, to: currentDate)
            let estimatedWords = readingDays * readingSpeed.wordsPerMinute * 20
            cards.append(CardData(id: .wordsRead, title: "Words Read", value: formatMillions(estimatedWords), subtitle: "\(readingSpeed.title.lowercased()) reading pace", chartData: ascendingData, icon: "book.pages", color: cardColor(.wordsRead), accentColor: cardAccent(.wordsRead), valueColor: cardValue(.wordsRead)))
        }

        return cards
    }

    private func days(from startDate: Date, to endDate: Date) -> Int {
        max(0, Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0)
    }

    private func formattedDistance(kilometers: Int) -> String {
        if useMetricUnits {
            return formatBillions(kilometers)
        }

        let miles = Double(kilometers) * 0.621371
        return String(format: "%.1fB", miles / 1_000_000_000.0)
    }

    private func formattedLength(meters: Double) -> String {
        if useMetricUnits {
            return formatDouble(meters) + "m"
        }

        return formatDouble(meters * 3.28084) + "ft"
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
