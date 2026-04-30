import SwiftUI
import UserNotifications

public struct MilestonesView: View {
    @AppStorage("userDOBTimestamp") private var userDOBTimestamp: Double = 0
    @StateObject private var notificationManager = NotificationManager.shared
    
    // Updates UI dynamically around midnight or when left open
    @State private var currentDate = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        let dob = Date(timeIntervalSince1970: userDOBTimestamp)
        let math = LifeMath(dateOfBirth: dob)
        let milestones = math.calculateMilestones()
        
        ZStack {
            Color.vitalzBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    
                    // Header
                    HStack {
                        Text("VITAL MILESTONES")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundColor(.vitalzGold)
                            .kerning(6)
                        Spacer()
                        
                        // Notifications Toggle/Opt-In
                        Button(action: {
                            setupNotifications(math: math)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: notificationManager.hasPermission ? "bell.badge.fill" : "bell.fill")
                                    .font(.system(size: 14))
                                Text(notificationManager.hasPermission ? "Active" : "Alert Me")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(notificationManager.hasPermission ? .vitalzGold : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.vitalzCard)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    VStack(spacing: 24) {
                        DynamicMilestoneCard(
                            titleLabel: "10,000th Day",
                            targetInSentence: "10,000th day alive",
                            date: milestones.tenThousandthDay,
                            iconSystemName: "sun.max",
                            currentDate: currentDate
                        )
                        
                        DynamicMilestoneCard(
                            titleLabel: "1 Billionth Second",
                            targetInSentence: "1 billionth second alive",
                            date: milestones.oneBillionthSecond,
                            iconSystemName: "hourglass",
                            currentDate: currentDate
                        )
                        
                        DynamicMilestoneCard(
                            titleLabel: "500M Heartbeats",
                            targetInSentence: "500,000,000th heartbeat",
                            date: milestones.fiveHundredMillionthHeartbeat,
                            iconSystemName: "heart.circle",
                            currentDate: currentDate
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                }
            }
        }
        .onReceive(timer) { input in
            currentDate = input
        }
        .onAppear {
            // Attempt to read current permission state silently on load
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    notificationManager.hasPermission = settings.authorizationStatus == .authorized
                }
            }
        }
    }
    
    private func setupNotifications(math: LifeMath) {
        notificationManager.requestAuthorization()
        
        let milestones = math.calculateMilestones()
        
        if let d = milestones.tenThousandthDay {
            notificationManager.scheduleMilestoneNotification(
                title: "10,000 Days Alive",
                body: "Today you mark your 10,000th sunrise on Earth. Make it incredible.",
                date: d,
                identifier: "milestone.10kdays"
            )
        }
        
        notificationManager.scheduleMilestoneNotification(
            title: "1 Billion Seconds",
            body: "Your one billionth tick of the clock has arrived. Every second counts.",
            date: milestones.oneBillionthSecond,
            identifier: "milestone.1bseconds"
        )
        
        notificationManager.scheduleMilestoneNotification(
            title: "500 Million Heartbeats",
            body: "Your heart just hit the 500 million mark. A phenomenal achievement.",
            date: milestones.fiveHundredMillionthHeartbeat,
            identifier: "milestone.500mheartbeats"
        )
    }
}

// MARK: - Subcomponents

struct DynamicMilestoneCard: View {
    let titleLabel: String
    let targetInSentence: String
    let date: Date?
    let iconSystemName: String
    let currentDate: Date
    
    private var isFuture: Bool {
        guard let d = date else { return false }
        return d > currentDate
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Left Custom Icon
            ZStack {
                Circle()
                    .fill(Color.vitalzBackground)
                    .frame(width: 56, height: 56)
                
                Image(systemName: iconSystemName)
                    .font(.system(size: 20, weight: .light))
                    // Dimmed if the event already happened
                    .foregroundColor(isFuture ? .vitalzGold : .gray.opacity(0.5))
            }
            .shadow(color: .vitalzShadow.opacity(0.5), radius: 5, x: 0, y: 3)
            
            // Text Content
            VStack(alignment: .leading, spacing: 10) {
                Text(titleLabel.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundColor(isFuture ? .vitalzText : .vitalzText.opacity(0.4))
                    .kerning(1.2)
                
                if let validDate = date {
                    DynamicMessageView(target: targetInSentence, date: validDate, currentDate: currentDate)
                } else {
                    Text("Date Unavailable")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 4)
            
            Spacer()
        }
        .padding(24)
        .background(Color.vitalzCard)
        .cornerRadius(24)
        .shadow(color: .vitalzShadow, radius: 15, x: 0, y: 10)
        // Wash out border style if event passed
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isFuture ? Color.clear : Color.vitalzText.opacity(0.05), lineWidth: 1)
        )
    }
}

/// Constructs the specific natural language strings requested
struct DynamicMessageView: View {
    let target: String
    let date: Date
    let currentDate: Date
    
    var body: some View {
        let calendar = Calendar.current
        
        if date > currentDate {
            let components = calendar.dateComponents([.day], from: currentDate, to: date)
            let days = components.day ?? 0
            
            if days > 0 {
                // Future milestone countdown
                Text("In ")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                + Text("\(days)")
                    // Gold highlight for the countdown digits
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(.vitalzGold)
                + Text(" days you hit your \(target)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            } else {
                Text("Happening within 24 hours!")
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundColor(.vitalzGold)
            }
        } else {
            // Past Milestone Calculation
            let components = calendar.dateComponents([.year, .month, .day], from: date, to: currentDate)
            let years = components.year ?? 0
            let months = components.month ?? 0
            let days = components.day ?? 0
            
            // Revert to a subtle styling for past events
            let baseStyle = Font.system(size: 13, weight: .medium)
            
            if years > 0 {
                Text("Passed ")
                    .font(baseStyle).foregroundColor(.gray)
                + Text("\(years) \(years == 1 ? "year" : "years")")
                    .font(baseStyle).foregroundColor(.vitalzText.opacity(0.4))
                + Text(" ago")
                    .font(baseStyle).foregroundColor(.gray)
            } else if months > 0 {
                Text("Passed ")
                    .font(baseStyle).foregroundColor(.gray)
                + Text("\(months) \(months == 1 ? "month" : "months")")
                    .font(baseStyle).foregroundColor(.vitalzText.opacity(0.4))
                + Text(" ago")
                    .font(baseStyle).foregroundColor(.gray)
            } else if days > 0 {
                Text("Passed ")
                    .font(baseStyle).foregroundColor(.gray)
                + Text("\(days) \(days == 1 ? "day" : "days")")
                    .font(baseStyle).foregroundColor(.vitalzText.opacity(0.4))
                + Text(" ago")
                    .font(baseStyle).foregroundColor(.gray)
            } else {
                Text("Reached today!")
                    .font(baseStyle).foregroundColor(.vitalzText.opacity(0.4))
            }
        }
    }
}

#Preview {
    MilestonesView()
}
