import SwiftUI

struct CardData: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
    let chartData: [CGFloat]
}

public struct DashboardView: View {
    @AppStorage("userDOBTimestamp") private var userDOBTimestamp: Double = 0
    @AppStorage("userName") private var userName: String = "John Doe"
    
    @State private var currentDate = Date()
    @State private var stats: LifeStats? = nil
    @State private var showingSettings = false
    
    @Namespace private var animation
    @State private var selectedCard: CardData? = nil
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.vitalzBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Profile Header
                    VStack(spacing: 8) {
                        Button(action: { showingSettings = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color.vitalzCard)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: .vitalzShadow, radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.vitalzBlue)
                                    .frame(width: 80, height: 80)
                            }
                        }
                        
                        Text(userName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.vitalzText)
                        
                        Text("V I T A L Z")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(.vitalzBlue)
                            .kerning(4)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    
                    if let stats = stats {
                        let cards = generateCards(from: stats)
                        
                        LazyVStack(spacing: 24) {
                            ForEach(cards) { card in
                                if selectedCard?.id != card.id {
                                    CompactCardView(card: card, animation: animation)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                selectedCard = card
                                            }
                                        }
                                } else {
                                    Color.clear
                                        .frame(height: 180) // Placeholder to maintain scroll position
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 80)
                    } else {
                        Color.clear.frame(height: 400)
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                // Top Blur for readability
                Color.clear
                    .frame(height: 0)
                    .background(.ultraThinMaterial)
            }
            
            // Expanded Card Overlay
            if let card = selectedCard {
                ExpandedCardView(card: card, animation: animation) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedCard = nil
                    }
                }
                .zIndex(1)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            updateStats(for: currentDate)
        }
        .onChange(of: userDOBTimestamp) { _ in
            updateStats(for: currentDate)
        }
        .onReceive(timer) { input in
            currentDate = input
            updateStats(for: input)
        }
    }
    
    private func updateStats(for date: Date) {
        let dob = Date(timeIntervalSince1970: userDOBTimestamp)
        let math = LifeMath(dateOfBirth: dob)
        self.stats = math.calculateStats(upTo: date)
    }
    
    private func formatLargeNumber(_ number: Int) -> String {
        return Self.numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    private func generateCards(from stats: LifeStats) -> [CardData] {
        let percentageSummersAhead = max(0.0, 100.0 - stats.percentageOf80YearLifeExpectancy)
        let ascendingData: [CGFloat] = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
        let descendingData: [CGFloat] = [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4]
        
        return [
            CardData(title: "Total Days Alive", value: formatLargeNumber(stats.totalDaysAlive), subtitle: "Every sunrise is a privilege.", chartData: ascendingData),
            CardData(title: "Total Heartbeats", value: formatLargeNumber(stats.estimatedTotalHeartbeats), subtitle: "The rhythm of your existence.", chartData: ascendingData),
            CardData(title: "Breaths Taken", value: formatLargeNumber(stats.estimatedBreathsTaken), subtitle: "Inhale the future, exhale the past.", chartData: ascendingData),
            CardData(title: "Times Blinked", value: formatLargeNumber(stats.estimatedBlinks), subtitle: "Capturing moments in the blink of an eye.", chartData: ascendingData),
            CardData(title: "Space Traveled (km)", value: formatLargeNumber(stats.distanceTraveledSpaceKm), subtitle: "Orbiting the sun at 29.78 km/s.", chartData: ascendingData),
            CardData(title: "Remaining Summers", value: String(format: "%.1f%%", percentageSummersAhead), subtitle: "Make every season unforgettable.", chartData: descendingData)
        ]
    }
}

// MARK: - Subcomponents

struct CompactCardView: View {
    let card: CardData
    var animation: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(card.title.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .kerning(1.5)
                .matchedGeometryEffect(id: "title\(card.id)", in: animation)
            
            Text(card.value)
                .font(.system(size: 42, weight: .bold, design: .default))
                .foregroundStyle(Color.vitalzGradient)
                .shadow(color: Color.vitalzBlue.opacity(0.15), radius: 8, x: 0, y: 3)
                .matchedGeometryEffect(id: "value\(card.id)", in: animation)
            
            Text(card.subtitle)
                .font(.system(size: 15, weight: .light, design: .default))
                .foregroundColor(.vitalzText.opacity(0.7))
                .matchedGeometryEffect(id: "subtitle\(card.id)", in: animation)
        }
        .padding(32)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.vitalzCard
                .matchedGeometryEffect(id: "bg\(card.id)", in: animation)
        )
        .cornerRadius(24)
        .shadow(color: .vitalzShadow, radius: 15, x: 0, y: 10)
    }
}

struct ExpandedCardView: View {
    let card: CardData
    var animation: Namespace.ID
    var onClose: () -> Void
    
    @State private var showDetails = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 24) {
                Text(card.title.uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.gray)
                    .kerning(1.5)
                    .matchedGeometryEffect(id: "title\(card.id)", in: animation)
                
                Text(card.value)
                    .font(.system(size: 56, weight: .bold, design: .default))
                    .foregroundStyle(Color.vitalzGradient)
                    .shadow(color: Color.vitalzBlue.opacity(0.2), radius: 10, x: 0, y: 5)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .matchedGeometryEffect(id: "value\(card.id)", in: animation)
                
                Text(card.subtitle)
                    .font(.system(size: 18, weight: .light, design: .default))
                    .foregroundColor(.vitalzText.opacity(0.8))
                    .matchedGeometryEffect(id: "subtitle\(card.id)", in: animation)
                
                if showDetails {
                    VStack(spacing: 32) {
                        Divider().padding(.vertical, 8)
                        
                        // Animated Bar Chart
                        HStack(alignment: .bottom, spacing: 16) {
                            ForEach(0..<card.chartData.count, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.vitalzGradient)
                                    .frame(width: 30, height: 120 * card.chartData[index])
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.05), value: showDetails)
                            }
                        }
                        .frame(height: 140)
                        
                        Spacer()
                        
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
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.vitalzBlue)
                            )
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.vitalzCard
                .matchedGeometryEffect(id: "bg\(card.id)", in: animation)
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                showDetails = true
            }
        }
    }
}

#Preview {
    DashboardView()
}

#Preview {
    DashboardView()
}

