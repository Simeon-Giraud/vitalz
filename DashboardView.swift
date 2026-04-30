import SwiftUI

public struct DashboardView: View {
    @AppStorage("userDOBTimestamp") private var userDOBTimestamp: Double = 0
    
    // Updates live metrics
    @State private var currentDate = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        // Derive state
        let dob = Date(timeIntervalSince1970: userDOBTimestamp)
        let math = LifeMath(dateOfBirth: dob)
        let stats = math.calculateStats(upTo: currentDate)
        
        let percentageLived = stats.percentageOf80YearLifeExpectancy
        let percentageSummersAhead = max(0.0, 100.0 - percentageLived)
        
        ScrollView(showsIndicators: false) {
            VStack(spacing: 50) { // Large negative space for premium breathing room
                
                // Minimal Header
                Text("V I T A L Z")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(.vitalzGold)
                    .kerning(8)
                    .padding(.top, 24)
                
                // Animated Hero Element
                CircularProgressArc(percentage: percentageLived)
                    .frame(height: 320)
                
                // Celebratory Premium Cards
                VStack(spacing: 32) {
                    PremiumStatCard(
                        title: "Total Days Alive",
                        value: formatLargeNumber(stats.totalDaysAlive),
                        subtitle: "Every sunrise is a privilege."
                    )
                    
                    PremiumStatCard(
                        title: "Total Heartbeats",
                        value: formatLargeNumber(stats.estimatedTotalHeartbeats),
                        subtitle: "The rhythm of your existence."
                    )
                    
                    PremiumStatCard(
                        title: "Remaining Summers",
                        value: String(format: "%.1f%%", percentageSummersAhead),
                        subtitle: "Make every season unforgettable."
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
        .background(Color.vitalzBackground.ignoresSafeArea())
        .onReceive(timer) { input in
            currentDate = input
        }
    }
    
    private func formatLargeNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Subcomponents

/// A large, luxuriously spaced card representing a singular statistic
struct PremiumStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .kerning(1.5)
            
            Text(value)
                // Distinctive large number display independent from the HeroStats modifier if needed,
                // but matching the aesthetic
                .font(.system(size: 42, weight: .medium, design: .serif))
                .foregroundColor(.vitalzGold)
                .shadow(color: Color.vitalzGold.opacity(0.15), radius: 8, x: 0, y: 3)
            
            Text(subtitle)
                .font(.system(size: 15, weight: .light, design: .serif))
                .foregroundColor(.vitalzText.opacity(0.7))
                .italic()
        }
        .padding(36) // Extensive padding for an airy, museum-like layout
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vitalzCard)
        .cornerRadius(24) // Soft, grand rounding
        // Ambient darkness shadow for depth against the pure black
        .shadow(color: Color.black.opacity(0.8), radius: 20, x: 0, y: 15)
    }
}

/// The beautifully animated core visual element
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
                    AngularGradient(
                        gradient: Gradient(colors: [.vitalzCard, .vitalzGold]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                // Glow effect mimicking a polished complication
                .shadow(color: .vitalzGold.opacity(0.35), radius: 15, x: 0, y: 0)
            
            // Center content
            VStack(spacing: 8) {
                // If it hits exactly an integer, drop the decimal, else show up to 1 decimal place
                Text(String(format: percentage.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f%%" : "%.1f%%", percentage))
                    .heroStatsStyle()
                    // If your Xcode complains about numeric text in SwiftUI < iOS 16, you can safely remove `.contentTransition`
                    .contentTransition(.numericText())
                
                Text("EXPLORED")
                    .font(.system(size: 11, weight: .bold, design: .serif))
                    .foregroundColor(.gray)
                    .kerning(4)
            }
        }
        .padding(40)
        .onAppear {
            // Ensure the percentage is constrained between 0 and 1
            let targetTrim = CGFloat(min(percentage / 100.0, 1.0))
            
            // Long, premium sweeping animation
            withAnimation(.easeInOut(duration: 2.2).delay(0.3)) {
                animatedEndTrim = targetTrim
            }
        }
    }
}

#Preview {
    DashboardView()
}
