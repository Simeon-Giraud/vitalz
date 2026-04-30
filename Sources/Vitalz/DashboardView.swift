import SwiftUI

public struct DashboardView: View {
    @AppStorage("userDOBTimestamp") private var userDOBTimestamp: Double = 0
    
    // Updates live metrics
    @State private var currentDate = Date()
    @State private var stats: LifeStats? = nil
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Cache the formatter so it is not allocated on every render
    private static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()
    
    public init() {}
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 50) { 
                
                // Minimal Header
                Text("V I T A L Z")
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.vitalzBlue)
                    .kerning(8)
                    .padding(.top, 24)
                
                if let stats = stats {
                    let percentageLived = stats.percentageOf80YearLifeExpectancy
                    let percentageSummersAhead = max(0.0, 100.0 - percentageLived)
                    
                    // Animated Hero Element
                    CircularProgressArc(percentage: percentageLived)
                        .frame(height: 320)
                    
                    // Expandable Premium Cards
                    VStack(spacing: 32) {
                        ExpandableStatCard(
                            title: "Total Days Alive",
                            value: formatLargeNumber(stats.totalDaysAlive),
                            subtitle: "Every sunrise is a privilege.",
                            chartData: [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
                        )
                        
                        ExpandableStatCard(
                            title: "Total Heartbeats",
                            value: formatLargeNumber(stats.estimatedTotalHeartbeats),
                            subtitle: "The rhythm of your existence.",
                            chartData: [0.3, 0.45, 0.55, 0.7, 0.8, 0.9, 1.0]
                        )
                        
                        ExpandableStatCard(
                            title: "Remaining Summers",
                            value: String(format: "%.1f%%", percentageSummersAhead),
                            subtitle: "Make every season unforgettable.",
                            chartData: [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4]
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                } else {
                    Color.clear.frame(height: 400)
                }
            }
        }
        .background(Color.vitalzBackground.ignoresSafeArea())
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
}

// MARK: - Subcomponents

struct ExpandableStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let chartData: [CGFloat]
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title.uppercased())
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)
                        .kerning(1.5)
                    
                    Text(value)
                        .font(.system(size: 42, weight: .bold, design: .default))
                        .foregroundStyle(Color.vitalzGradient)
                        .shadow(color: Color.vitalzBlue.opacity(0.15), radius: 8, x: 0, y: 3)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .foregroundColor(.gray)
            }
            
            Text(subtitle)
                .font(.system(size: 15, weight: .light, design: .default))
                .foregroundColor(.vitalzText.opacity(0.7))
            
            if isExpanded {
                VStack(spacing: 24) {
                    Divider().padding(.vertical, 8)
                    
                    // Simple Animated Bar Chart
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(0..<chartData.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.vitalzGradient)
                                .frame(width: 20, height: 60 * chartData[index])
                                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.05), value: isExpanded)
                        }
                    }
                    .frame(height: 70)
                    .padding(.bottom, 8)
                    
                    Button(action: {
                        ShareHelper.shareMilestone(title: title, subtitle: "Vitalz Checkpoint", statValue: value)
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
                                .fill(Color.vitalzBlue)
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(36)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vitalzCard)
        .cornerRadius(24)
        .shadow(color: .vitalzShadow, radius: 20, x: 0, y: 15)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                isExpanded.toggle()
            }
        }
    }
}

struct CircularProgressArc: View {
    let percentage: Double
    @State private var animatedEndTrim: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            // Unfilled track
            Circle()
                .stroke(Color.vitalzCard, lineWidth: 10)
            
            // Animated, filled track
            Circle()
                .trim(from: 0, to: animatedEndTrim)
                .stroke(
                    Color.vitalzGradient,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.vitalzBlue.opacity(0.35), radius: 15, x: 0, y: 0)
            
            // Center content
            VStack(spacing: 8) {
                Text(String(format: percentage.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f%%" : "%.1f%%", percentage))
                    .heroStatsStyle()
                    .contentTransition(.numericText())
                
                Text("EXPLORED")
                    .font(.system(size: 11, weight: .bold, design: .default))
                    .foregroundColor(.gray)
                    .kerning(4)
            }
        }
        .padding(40)
        .onAppear {
            let targetTrim = CGFloat(min(percentage / 100.0, 1.0))
            withAnimation(.easeInOut(duration: 2.2).delay(0.3)) {
                animatedEndTrim = targetTrim
            }
        }
    }
}

#Preview {
    DashboardView()
}

