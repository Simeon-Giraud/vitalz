import SwiftUI
import UserNotifications

public struct MilestonesView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var currentDate = Date()
    @State private var selectedCategory: Milestone.MilestoneCategory? = nil
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
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
        let profile = profileStore.selectedProfile
        let math = LifeMath(dateOfBirth: profile.effectiveDateOfBirth)
        var allMilestones = math.calculateMilestones()

        // Append Shared Bonds milestones for each tracked person
        for person in profile.trackedPeople {
            allMilestones.append(contentsOf: math.calculateSharedMilestones(for: person))
        }

        // Re-sort after appending
        allMilestones.sort { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
        
        ZStack {
            Color.vitalzBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // Header
                    HStack {
                        Text("VITAL MILESTONES")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(.vitalzAccent)
                            .kerning(6)
                        Spacer()
                        
                        Button(action: {
                            setupNotifications(milestones: allMilestones)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: notificationManager.hasPermission ? "bell.badge.fill" : "bell.fill")
                                    .font(.system(size: 14))
                                Text(notificationManager.hasPermission ? "Active" : "Alert Me")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(notificationManager.hasPermission ? .vitalzAccent : .vitalzSecondaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.vitalzCard)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // Next Up Banner
                    if let nextMilestone = allMilestones.first(where: { ($0.date ?? .distantPast) > currentDate }) {
                        NextMilestoneBanner(milestone: nextMilestone, currentDate: currentDate)
                            .padding(.horizontal, 24)
                    }
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            CategoryPill(title: "All", isSelected: selectedCategory == nil) {
                                withAnimation(.spring(response: 0.3)) { selectedCategory = nil }
                            }
                            
                            ForEach(Milestone.MilestoneCategory.allCases, id: \.rawValue) { cat in
                                CategoryPill(title: categoryShortName(cat), isSelected: selectedCategory == cat) {
                                    withAnimation(.spring(response: 0.3)) { selectedCategory = cat }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Milestone Cards by Category
                    let filtered = selectedCategory == nil ? allMilestones : allMilestones.filter { $0.category == selectedCategory }
                    let grouped = Dictionary(grouping: filtered, by: { $0.category })
                    
                    ForEach(Milestone.MilestoneCategory.allCases, id: \.rawValue) { category in
                        if let items = grouped[category], !items.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                // Section Header
                                HStack(spacing: 10) {
                                    Image(systemName: categoryIcon(category))
                                        .font(.system(size: 14))
                                        .foregroundColor(categoryColor(category))
                                    Text(category.rawValue.uppercased())
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(categoryColor(category))
                                        .kerning(1.5)
                                }
                                .padding(.horizontal, 24)
                                
                                // Timeline
                                VStack(spacing: 12) {
                                    ForEach(items) { milestone in
                                        TimelineMilestoneRow(
                                            milestone: milestone,
                                            currentDate: currentDate,
                                            accentColor: categoryColor(milestone.category),
                                            isLast: milestone.id == items.last?.id
                                        )
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                    }
                    
                    Spacer(minLength: 80)
                }
            }
            .overlay(alignment: .top) {
                topFade
            }
        }
        .onReceive(timer) { input in
            currentDate = input
        }
        .onAppear {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    notificationManager.hasPermission = settings.authorizationStatus == .authorized
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func categoryShortName(_ cat: Milestone.MilestoneCategory) -> String {
        switch cat {
        case .chronological: return "Time"
        case .biological: return "Body"
        case .cosmic: return "Cosmic"
        case .quirky: return "Quirky"
        case .lifeAnchors: return "Life %"
        case .bonds: return "Bonds"
        }
    }
    
    private func categoryIcon(_ cat: Milestone.MilestoneCategory) -> String {
        switch cat {
        case .chronological: return "clock"
        case .biological: return "heart"
        case .cosmic: return "moon.stars"
        case .quirky: return "sparkles"
        case .lifeAnchors: return "chart.bar"
        case .bonds: return "person.2.fill"
        }
    }
    
    private func categoryColor(_ cat: Milestone.MilestoneCategory) -> Color {
        switch cat {
        case .chronological: return .yellow
        case .biological: return .red
        case .cosmic: return .blue
        case .quirky: return .purple
        case .lifeAnchors: return .green
        case .bonds: return .pink
        }
    }
    
    private func setupNotifications(milestones: [Milestone]) {
        notificationManager.requestAuthorization()
        
        let futureMilestones = milestones.filter { ($0.date ?? .distantPast) > currentDate }
        
        // Schedule up to 10 upcoming milestones (iOS limit is 64 pending)
        for milestone in futureMilestones.prefix(10) {
            guard let date = milestone.date else { continue }
            notificationManager.scheduleMilestoneNotification(
                title: milestone.title,
                body: milestone.subtitle,
                date: date,
                identifier: "milestone.\(milestone.id)"
            )
        }
    }
}

// MARK: - Next Milestone Banner

struct NextMilestoneBanner: View {
    let milestone: Milestone
    let currentDate: Date
    
    var body: some View {
        let daysLeft = Calendar.current.dateComponents([.day], from: currentDate, to: milestone.date ?? currentDate).day ?? 0
        
        VStack(spacing: 16) {
            HStack {
                Text("NEXT UP")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.vitalzSecondaryText)
                    .kerning(2)
                Spacer()
                Image(systemName: milestone.icon)
                    .foregroundColor(.vitalzSecondaryText)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(milestone.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.vitalzText)
                Spacer()
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(daysLeft)")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(.vitalzAccent)
                Text("days away")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.vitalzSecondaryText)
                Spacer()
            }
            
            Text(milestone.subtitle)
                .font(.system(size: 13))
                .foregroundColor(.vitalzSecondaryText)
                .lineSpacing(3)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.vitalzCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.vitalzAccent.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .vitalzShadow, radius: 15, x: 0, y: 10)
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .vitalzText : .vitalzSecondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.vitalzAccent.opacity(0.3) : Color.vitalzCard)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.vitalzAccent.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        }
    }
}

// MARK: - Timeline Milestone Row

struct TimelineMilestoneRow: View {
    let milestone: Milestone
    let currentDate: Date
    let accentColor: Color
    let isLast: Bool
    
    private var isFuture: Bool {
        guard let d = milestone.date else { return false }
        return d > currentDate
    }
    
    private var isPast: Bool { !isFuture }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline dot + line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isFuture ? accentColor : Color.vitalzSecondaryText.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    if isFuture {
                        Circle()
                            .fill(accentColor.opacity(0.3))
                            .frame(width: 20, height: 20)
                    }
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.vitalzDivider)
                        .frame(width: 2)
                        .frame(minHeight: 40)
                }
            }
            
            // Card content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(milestone.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(isFuture ? .vitalzText : .vitalzSecondaryText.opacity(0.6))
                    
                    Spacer()
                    
                    if let date = milestone.date {
                        Text(formattedDate(date))
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(isFuture ? accentColor.opacity(0.7) : .vitalzSecondaryText.opacity(0.5))
                    }
                }
                
                Text(milestone.subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(isFuture ? .vitalzSecondaryText : .vitalzSecondaryText.opacity(0.5))
                    .lineSpacing(2)
                
                if isFuture, let date = milestone.date {
                    let days = Calendar.current.dateComponents([.day], from: currentDate, to: date).day ?? 0
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(days == 0 ? "Today!" : "\(days) days away")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(accentColor.opacity(0.8))
                    .padding(.top, 2)
                } else if isPast, let date = milestone.date {
                    let components = Calendar.current.dateComponents([.year, .month], from: date, to: currentDate)
                    let years = components.year ?? 0
                    let months = components.month ?? 0
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                        if years > 0 {
                            Text("\(years)y \(months)m ago")
                                .font(.system(size: 11, weight: .medium))
                        } else if months > 0 {
                            Text("\(months)m ago")
                                .font(.system(size: 11, weight: .medium))
                        } else {
                            Text("Recently")
                                .font(.system(size: 11, weight: .medium))
                        }
                    }
                    .foregroundColor(.vitalzSecondaryText.opacity(0.5))
                    .padding(.top, 2)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isFuture ? Color.vitalzCard : Color.vitalzCard.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isFuture ? accentColor.opacity(0.1) : Color.clear, lineWidth: 1)
            )
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    MilestonesView()
        .environmentObject(ProfileStore())
}
