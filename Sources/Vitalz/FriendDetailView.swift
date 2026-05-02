import SwiftUI

public struct FriendDetailView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    let person: TrackedPerson
    let onClose: () -> Void

    @State private var currentDate = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 24)

                HStack(spacing: 16) {
                    ProfileAvatarView(imageData: person.imageData, size: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.vitalzAccent.opacity(0.5), lineWidth: 3)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(person.name.isEmpty ? "Friend" : person.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.vitalzText)

                        Text(person.relationship.isEmpty ? "Friend" : person.relationship)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.vitalzSecondaryText)
                    }

                    Spacer()

                    VitalzGlassButton(shape: .circle, isProminent: false, action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.vitalzSecondaryText)
                            .padding(10)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        let stats = generateStats()

                        // Grid of stats
                        let columns = [GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(stats) { stat in
                                StatBox(stat: stat)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                }
            }
            .background(Color.vitalzBackground)
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 32, topTrailing: 32)))
            .shadow(color: .black.opacity(0.2), radius: 20, y: -5)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.85)
        }
        .ignoresSafeArea(edges: .bottom)
        .onReceive(timer) { input in
            currentDate = input
        }
    }

    private func generateStats() -> [FriendStat] {
        var stats: [FriendStat] = []

        let myProfile = profileStore.selectedProfile

        let metDate = person.metDate
        let sharedDays = max(0, Calendar.current.dateComponents([.day], from: calendarStartOfDay(metDate), to: calendarStartOfDay(currentDate)).day ?? 0)
        let sharedSeconds = max(0, Int(currentDate.timeIntervalSince(metDate)))
        let sharedHeartbeats = Int((Double(sharedSeconds) / 60.0) * 70.0 * 2.0)

        let totalDaysAlive = max(1, Calendar.current.dateComponents([.day], from: calendarStartOfDay(myProfile.dateOfBirth), to: calendarStartOfDay(currentDate)).day ?? 1)
        let percentOfMyLife = min(100.0, (Double(sharedDays) / Double(totalDaysAlive)) * 100.0)

        // Count Dec-Feb periods
        var winters = 0
        var d = metDate
        let end = currentDate
        while d < end {
            let month = Calendar.current.component(.month, from: d)
            if month == 12 {
                winters += 1
                if let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: d) {
                    d = nextYear
                } else {
                    break
                }
            } else {
                if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: d) {
                    d = nextMonth
                } else {
                    break
                }
            }
        }

        let fullMoons = Int(Double(sharedDays) / 29.53)

        stats.append(FriendStat(title: "Shared Days", value: formatLargeNumber(sharedDays), subtitle: "on Earth together", icon: "sun.max.fill", color: .vitalzAccent))
        stats.append(FriendStat(title: "Combined Beats", value: formatMillions(sharedHeartbeats), subtitle: "heartbeats since meeting", icon: "heart.fill", color: .red))
        stats.append(FriendStat(title: "% of My Life", value: formatDouble(percentOfMyLife) + "%", subtitle: "spent knowing them", icon: "chart.pie.fill", color: .orange))
        stats.append(FriendStat(title: "Winters", value: "\(winters)", subtitle: "survived together", icon: "snowflake", color: .cyan))
        stats.append(FriendStat(title: "Full Moons", value: "\(fullMoons)", subtitle: "witnessed together", icon: "moon.fill", color: .purple))
        stats.append(FriendStat(title: "Shared Sunsets", value: formatLargeNumber(sharedDays), subtitle: "one for each day", icon: "sunset.fill", color: .yellow))

        if let dob = person.dateOfBirth {
            let ageDays = max(0, Calendar.current.dateComponents([.day], from: calendarStartOfDay(dob), to: calendarStartOfDay(currentDate)).day ?? 0)
            let ageYears = Double(ageDays) / 365.25
            stats.append(FriendStat(title: "Their Age", value: formatDouble(ageYears, decimals: 1), subtitle: "years old", icon: "birthday.cake.fill", color: .pink))
        }

        return stats
    }

    private func calendarStartOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func formatLargeNumber(_ number: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    private func formatMillions(_ number: Int) -> String {
        if number >= 1_000_000 {
            let millions = Double(number) / 1_000_000.0
            return String(format: "%.1fM", millions)
        } else {
            return formatLargeNumber(number)
        }
    }

    private func formatDouble(_ value: Double, decimals: Int = 1) -> String {
        return String(format: "%.\(decimals)f", value)
    }
}

struct FriendStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct StatBox: View {
    let stat: FriendStat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: stat.icon)
                .font(.system(size: 20))
                .foregroundColor(stat.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(stat.value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.vitalzText)

                Text(stat.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.vitalzText)

                Text(stat.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.vitalzSecondaryText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vitalzCard)
        .cornerRadius(20)
    }
}
