import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Configurable Stat Enum

/// The stat the user picks via long-press → Edit Widget.
enum WidgetStat: String, AppEnum, CaseIterable {
    case daysOnEarth
    case heartbeats
    case breathsTaken
    case fullMoons
    case hoursSlept
    case eraShare
    case sharedDays
    case lifeProgress

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Stat")

    static var caseDisplayRepresentations: [WidgetStat: DisplayRepresentation] {
        [
            .daysOnEarth:   .init(title: "Days on Earth",  image: .init(systemName: "calendar")),
            .heartbeats:    .init(title: "Heartbeats",     image: .init(systemName: "heart.fill")),
            .breathsTaken:  .init(title: "Breaths Taken",  image: .init(systemName: "wind")),
            .fullMoons:     .init(title: "Full Moons",     image: .init(systemName: "moon.fill")),
            .hoursSlept:    .init(title: "Hours Slept",    image: .init(systemName: "bed.double.fill")),
            .eraShare:      .init(title: "Era Share",      image: .init(systemName: "sparkles")),
            .sharedDays:    .init(title: "Shared Days",    image: .init(systemName: "person.2.fill")),
            .lifeProgress:  .init(title: "Life Progress",  image: .init(systemName: "chart.bar.fill")),
        ]
    }

    /// The tiny, heavily tracked caption displayed beneath the value.
    var caption: String {
        switch self {
        case .daysOnEarth:  return "DAYS ON EARTH"
        case .heartbeats:   return "HEARTBEATS"
        case .breathsTaken: return "BREATHS TAKEN"
        case .fullMoons:    return "FULL MOONS"
        case .hoursSlept:   return "HOURS SLEPT"
        case .eraShare:     return "ERA SHARE"
        case .sharedDays:   return "SHARED DAYS"
        case .lifeProgress: return "LIFE PROGRESS"
        }
    }
}

// MARK: - Configuration Intent

struct SelectStatIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Stat"
    static var description: IntentDescription = "Choose which life stat to display on your widget."

    @Parameter(title: "Stat", default: .daysOnEarth)
    var stat: WidgetStat
}

// MARK: - Timeline Entry

struct VitalzWidgetEntry: TimelineEntry {
    let date: Date
    let statValue: String
    let statCaption: String
    let hasData: Bool
}

// MARK: - Timeline Provider

struct VitalzStatProvider: AppIntentTimelineProvider {
    typealias Intent = SelectStatIntent
    typealias Entry = VitalzWidgetEntry

    func placeholder(in context: Context) -> Entry {
        VitalzWidgetEntry(date: .now, statValue: "8,401", statCaption: "DAYS ON EARTH", hasData: true)
    }

    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        computeEntry(for: configuration.stat, at: .now)
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        let now = Date()
        let entry = computeEntry(for: configuration.stat, at: now)

        // Schedule the next update at the start of tomorrow (midnight)
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now) ?? now)

        return Timeline(entries: [entry], policy: .after(tomorrow))
    }

    // MARK: - Computation

    private func computeEntry(for stat: WidgetStat, at date: Date) -> Entry {
        guard let profile = WidgetDataBridge.readProfile() else {
            return VitalzWidgetEntry(date: date, statValue: "—", statCaption: "NO DATA", hasData: false)
        }

        let math = LifeMath(dateOfBirth: profile.dateOfBirth)
        let stats = math.calculateStats(upTo: date)
        let calendar = Calendar.current

        let value: String
        switch stat {
        case .daysOnEarth:
            value = formatLargeNumber(stats.totalDaysAlive)

        case .heartbeats:
            value = formatCompact(stats.estimatedTotalHeartbeats)

        case .breathsTaken:
            value = formatCompact(stats.estimatedBreathsTaken)

        case .fullMoons:
            value = formatLargeNumber(stats.fullMoonsWitnessed)

        case .hoursSlept:
            value = formatLargeNumber(Int(stats.estimatedHoursSlept))

        case .eraShare:
            if let hobby = profile.hobbies.first(where: { $0.isEnabled }) {
                let hobbyDays = max(0, calendar.dateComponents([.day], from: hobby.startDate, to: date).day ?? 0)
                let pct = stats.totalDaysAlive > 0 ? (Double(hobbyDays) / Double(stats.totalDaysAlive)) * 100.0 : 0
                value = String(format: "%.1f%%", pct)
            } else {
                value = "—"
            }

        case .sharedDays:
            if let person = profile.trackedPeople.first {
                let shared = max(0, calendar.dateComponents([.day], from: person.metDate, to: date).day ?? 0)
                value = formatLargeNumber(shared)
            } else {
                value = "—"
            }

        case .lifeProgress:
            value = String(format: "%.1f%%", stats.percentageOf80YearLifeExpectancy)
        }

        return VitalzWidgetEntry(date: date, statValue: value, statCaption: stat.caption, hasData: true)
    }

    // MARK: - Formatting

    private func formatLargeNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    private func formatCompact(_ n: Int) -> String {
        if n >= 1_000_000_000 {
            return String(format: "%.1fB", Double(n) / 1_000_000_000.0)
        } else if n >= 1_000_000 {
            return String(format: "%.1fM", Double(n) / 1_000_000.0)
        } else {
            return formatLargeNumber(n)
        }
    }
}

// MARK: - Widget View

struct VitalzWidgetEntryView: View {
    let entry: VitalzWidgetEntry

    var body: some View {
        ZStack {
            // Pure white canvas — the negative space IS the design
            Color.white

            if entry.hasData {
                VStack(spacing: 6) {
                    Text(entry.statValue)
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(Color(white: 0.1))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)

                    Text(entry.statCaption)
                        .font(.system(size: 9, weight: .bold))
                        .kerning(3)
                        .foregroundColor(Color(white: 0.45))
                }
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 8) {
                    Text("—")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(Color(white: 0.8))

                    Text("OPEN VITALZ")
                        .font(.system(size: 9, weight: .bold))
                        .kerning(3)
                        .foregroundColor(Color(white: 0.55))
                }
            }
        }
        .containerBackground(.white, for: .widget)
    }
}

// MARK: - Widget Definition

struct VitalzStatWidget: Widget {
    let kind = "VitalzStatWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectStatIntent.self,
            provider: VitalzStatProvider()
        ) { entry in
            VitalzWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Vitalz")
        .description("Your life, at a glance.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    VitalzStatWidget()
} timeline: {
    VitalzWidgetEntry(date: .now, statValue: "8,401", statCaption: "DAYS ON EARTH", hasData: true)
    VitalzWidgetEntry(date: .now, statValue: "2.7B", statCaption: "HEARTBEATS", hasData: true)
    VitalzWidgetEntry(date: .now, statValue: "34.2%", statCaption: "LIFE PROGRESS", hasData: true)
}
