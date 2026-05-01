import Foundation

/// A data model containing current life statistics.
public struct LifeStats {
    public let totalDaysAlive: Int
    public let totalSecondsAlive: Int
    public let estimatedTotalHeartbeats: Int
    public let estimatedHoursSlept: Double
    public let estimatedBreathsTaken: Int
    public let distanceTraveledSpaceKm: Int
    public let estimatedBlinks: Int
    public let hairGrowthMeters: Double
    public let fullMoonsWitnessed: Int
    public let jupiterAge: Double
    public let phoneVoidYears: Double
    public let caffeineRiverLiters: Int
    public let percentageOf80YearLifeExpectancy: Double
}

/// A single milestone event with category, date, and display metadata.
public struct Milestone: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let date: Date?
    public let icon: String
    public let category: MilestoneCategory
    
    public enum MilestoneCategory: String, CaseIterable {
        case chronological = "Chronological Titans"
        case biological = "Biological Engines"
        case cosmic = "Cosmic Perspective"
        case quirky = "Symmetries & Palindromes"
        case lifeAnchors = "Statistical Life Anchors"
    }
}

/// A pure logic model that calculates statistics and milestones based on a Date of Birth.
public struct LifeMath {
    public let dateOfBirth: Date
    
    // Constants used for calculation
    private let heartbeatsPerMinute = 70
    private let sleepHoursPerDay = 8.0
    private let expectedLifeYears: Double = 80.0
    private let breathsPerMinute = 16
    private let blinksPerMinuteAwake = 15
    private let earthOrbitSpeedKmPerSecond = 29.78
    private let hairGrowthMetersPerDay = 0.00044 // 0.44 mm per day
    private let daysPerFullMoon = 29.53
    private let earthYearsPerJupiterYear = 11.86
    private var averagePhoneHoursPerDay = 3.0
    private var averageCoffeeLitersPerDay = 0.25
    private let caffeineStartAgeYears = 15.0
    
    /// Initialize with a specific Date of Birth and optional habits.
    public init(
        dateOfBirth: Date,
        averagePhoneHoursPerDay: Double? = nil,
        dailyCoffeeCups: Int? = nil
    ) {
        self.dateOfBirth = dateOfBirth
        if let phoneHours = averagePhoneHoursPerDay, phoneHours > 0 {
            self.averagePhoneHoursPerDay = phoneHours
        }
        if let coffeeCups = dailyCoffeeCups, coffeeCups > 0 {
            // Assuming 1 cup = 0.25 liters
            self.averageCoffeeLitersPerDay = Double(coffeeCups) * 0.25
        }
    }
    
    /// Calculates the current life statistics based on the provided date of birth.
    ///
    /// - Parameter currentDate: The date to calculate statistics up to. Defaults to the current date.
    /// - Returns: A `LifeStats` model containing the calculated metrics.
    public func calculateStats(upTo currentDate: Date = Date()) -> LifeStats {
        let calendar = Calendar.current
        
        // Prevent negative values if future date of birth is passed accidentally
        let timeIntervalAlive = currentDate.timeIntervalSince(dateOfBirth)
        let totalSecondsAlive = max(0, Int(timeIntervalAlive))
        
        let daysAlive = calendar.dateComponents([.day], from: dateOfBirth, to: currentDate).day ?? 0
        let totalDaysAlive = max(0, daysAlive)
        
        // Heartbeats calculation (70 bpm)
        // Ensure we calculate based on the overall seconds passing to avoid minutes rounding off precision
        let estimatedTotalHeartbeats = Int((Double(totalSecondsAlive) / 60.0) * Double(heartbeatsPerMinute))
        
        // Sleep calculation (8 hours per day)
        let estimatedHoursSlept = Double(totalDaysAlive) * sleepHoursPerDay
        
        // Exact percentage of an 80-year life lived
        let lifeExpectancySeconds = expectedLifeYears * 365.25 * 24.0 * 60.0 * 60.0
        let percentage = (Double(totalSecondsAlive) / lifeExpectancySeconds) * 100.0
        let percentageOf80YearLifeExpectancy = max(0.0, percentage) 
        
        // New stats
        let estimatedBreathsTaken = Int((Double(totalSecondsAlive) / 60.0) * Double(breathsPerMinute))
        let distanceTraveledSpaceKm = Int(Double(totalSecondsAlive) * earthOrbitSpeedKmPerSecond)
        
        let awakeHoursPerDay = 24.0 - sleepHoursPerDay
        let awakeMinutesTotal = Double(totalDaysAlive) * awakeHoursPerDay * 60.0
        let estimatedBlinks = Int(awakeMinutesTotal * Double(blinksPerMinuteAwake))
        
        let hairGrowthMeters = Double(totalDaysAlive) * hairGrowthMetersPerDay
        let fullMoonsWitnessed = Int(Double(totalDaysAlive) / daysPerFullMoon)
        
        let ageInEarthYears = Double(totalDaysAlive) / 365.25
        let jupiterAge = ageInEarthYears / earthYearsPerJupiterYear
        
        let phoneVoidYears = (Double(totalDaysAlive) * averagePhoneHoursPerDay) / 24.0 / 365.25
        
        let yearsDrinkingCoffee = max(0.0, ageInEarthYears - caffeineStartAgeYears)
        let caffeineRiverLiters = Int(yearsDrinkingCoffee * 365.25 * averageCoffeeLitersPerDay)
        
        return LifeStats(
            totalDaysAlive: totalDaysAlive,
            totalSecondsAlive: totalSecondsAlive,
            estimatedTotalHeartbeats: estimatedTotalHeartbeats,
            estimatedHoursSlept: estimatedHoursSlept,
            estimatedBreathsTaken: estimatedBreathsTaken,
            distanceTraveledSpaceKm: distanceTraveledSpaceKm,
            estimatedBlinks: estimatedBlinks,
            hairGrowthMeters: hairGrowthMeters,
            fullMoonsWitnessed: fullMoonsWitnessed,
            jupiterAge: jupiterAge,
            phoneVoidYears: phoneVoidYears,
            caffeineRiverLiters: caffeineRiverLiters,
            percentageOf80YearLifeExpectancy: percentageOf80YearLifeExpectancy
        )
    }
    
    /// Calculates a comprehensive set of life milestones across multiple categories.
    ///
    /// - Returns: An array of `Milestone` models sorted by date within each category.
    public func calculateMilestones() -> [Milestone] {
        let calendar = Calendar.current
        let beatsPerSecond = Double(heartbeatsPerMinute) / 60.0
        let breathsPerSecond = Double(breathsPerMinute) / 60.0
        let awakeHoursPerDay = 24.0 - sleepHoursPerDay
        let earthOrbitSpeedMilesPerYear = 584_000_000.0
        let secondsPerYear = 365.25 * 24.0 * 3600.0
        
        var milestones: [Milestone] = []
        
        // ═══════════════════════════════════════════
        // MARK: Chronological Titans
        // ═══════════════════════════════════════════
        
        // Days
        let dayMilestones: [(Int, String)] = [
            (10_000, "10,000th Day"),
            (15_000, "15,000th Day"),
            (20_000, "20,000th Day"),
            (25_000, "25,000th Day"),
        ]
        for (days, title) in dayMilestones {
            let date = calendar.date(byAdding: .day, value: days, to: dateOfBirth)
            milestones.append(Milestone(
                id: "day.\(days)", title: title,
                subtitle: "You will have been alive for \(formatNumber(days)) sunrises",
                date: date, icon: "sun.max", category: .chronological
            ))
        }
        
        // Weeks
        let weekMilestones: [(Int, String)] = [
            (1_000, "1,000th Week"),
            (2_000, "2,000th Week"),
        ]
        for (weeks, title) in weekMilestones {
            let date = calendar.date(byAdding: .day, value: weeks * 7, to: dateOfBirth)
            milestones.append(Milestone(
                id: "week.\(weeks)", title: title,
                subtitle: "\(formatNumber(weeks)) Mondays experienced",
                date: date, icon: "calendar", category: .chronological
            ))
        }
        
        // Months
        let monthMilestones: [(Int, String)] = [
            (500, "500th Month"),
            (1_000, "1,000th Month"),
        ]
        for (months, title) in monthMilestones {
            let date = calendar.date(byAdding: .month, value: months, to: dateOfBirth)
            milestones.append(Milestone(
                id: "month.\(months)", title: title,
                subtitle: "\(formatNumber(months)) calendar pages turned",
                date: date, icon: "calendar.badge.clock", category: .chronological
            ))
        }
        
        // Seconds
        let secondMilestones: [(Double, String, String)] = [
            (100_000_000, "100M Seconds", "One hundred million ticks of the clock"),
            (500_000_000, "500M Seconds", "Half a billion moments lived"),
            (1_000_000_000, "1 Billion Seconds", "Your billionth tick arrives — a monumental moment"),
            (1_500_000_000, "1.5 Billion Seconds", "One and a half billion seconds of existence"),
            (2_000_000_000, "2 Billion Seconds", "Two billion seconds — a rare accomplishment"),
        ]
        for (seconds, title, subtitle) in secondMilestones {
            let date = dateOfBirth.addingTimeInterval(seconds)
            milestones.append(Milestone(
                id: "seconds.\(Int(seconds))", title: title,
                subtitle: subtitle,
                date: date, icon: "hourglass", category: .chronological
            ))
        }
        
        // 100,000 Hours Awake
        let awakeSecondsTarget = 100_000.0 * 3600.0
        let totalSecondsForAwake = awakeSecondsTarget / (awakeHoursPerDay / 24.0)
        milestones.append(Milestone(
            id: "awake.100k", title: "100,000 Hours Awake",
            subtitle: "One hundred thousand hours of conscious experience",
            date: dateOfBirth.addingTimeInterval(totalSecondsForAwake),
            icon: "eye", category: .chronological
        ))
        
        // ═══════════════════════════════════════════
        // MARK: Biological Engines
        // ═══════════════════════════════════════════
        
        // Heartbeats
        let heartbeatMilestones: [(Double, String)] = [
            (500_000_000, "500M Heartbeats"),
            (1_000_000_000, "1 Billion Heartbeats"),
            (2_000_000_000, "2 Billion Heartbeats"),
            (3_000_000_000, "3 Billion Heartbeats"),
        ]
        for (beats, title) in heartbeatMilestones {
            let seconds = beats / beatsPerSecond
            milestones.append(Milestone(
                id: "heartbeat.\(Int(beats))", title: title,
                subtitle: "Your heart's \(formatNumber(Int(beats))) drum beats",
                date: dateOfBirth.addingTimeInterval(seconds),
                icon: "heart.circle", category: .biological
            ))
        }
        
        // Breaths
        let breathMilestones: [(Double, String)] = [
            (100_000_000, "100M Breaths"),
            (250_000_000, "250M Breaths"),
            (500_000_000, "500M Breaths"),
        ]
        for (breaths, title) in breathMilestones {
            let seconds = breaths / breathsPerSecond
            milestones.append(Milestone(
                id: "breath.\(Int(breaths))", title: title,
                subtitle: "\(formatNumber(Int(breaths))) inhales and exhales",
                date: dateOfBirth.addingTimeInterval(seconds),
                icon: "wind", category: .biological
            ))
        }
        
        // 100,000 Hours Slept
        let sleepSecondsTarget = 100_000.0 * 3600.0
        let totalSecondsForSleep = sleepSecondsTarget / (sleepHoursPerDay / 24.0)
        milestones.append(Milestone(
            id: "sleep.100k", title: "100,000 Hours Slept",
            subtitle: "Over eleven years spent in dreamland",
            date: dateOfBirth.addingTimeInterval(totalSecondsForSleep),
            icon: "moon.zzz", category: .biological
        ))
        
        // ═══════════════════════════════════════════
        // MARK: Cosmic Perspective
        // ═══════════════════════════════════════════
        
        // Sunrises (same as days)
        let sunriseMilestones: [(Int, String)] = [
            (10_000, "10,000th Sunrise"),
            (20_000, "20,000th Sunrise"),
        ]
        for (days, title) in sunriseMilestones {
            let date = calendar.date(byAdding: .day, value: days, to: dateOfBirth)
            milestones.append(Milestone(
                id: "sunrise.\(days)", title: title,
                subtitle: "The sun has risen for you \(formatNumber(days)) times",
                date: date, icon: "sunrise", category: .cosmic
            ))
        }
        
        // Full Moons
        let moonMilestones: [(Int, String)] = [
            (100, "100th Full Moon"),
            (500, "500th Full Moon"),
            (1_000, "1,000th Full Moon"),
        ]
        for (moons, title) in moonMilestones {
            let days = Int(Double(moons) * daysPerFullMoon)
            let date = calendar.date(byAdding: .day, value: days, to: dateOfBirth)
            milestones.append(Milestone(
                id: "moon.\(moons)", title: title,
                subtitle: "\(formatNumber(moons)) full moons witnessed in your lifetime",
                date: date, icon: "moon", category: .cosmic
            ))
        }
        
        // Space Travel (miles)
        let spaceMilestones: [(Double, String)] = [
            (10_000_000_000, "10 Billion Miles"),
            (25_000_000_000, "25 Billion Miles"),
        ]
        for (miles, title) in spaceMilestones {
            let years = miles / earthOrbitSpeedMilesPerYear
            let seconds = years * secondsPerYear
            milestones.append(Milestone(
                id: "space.\(Int(miles))", title: title,
                subtitle: "Traveled through space aboard Spaceship Earth",
                date: dateOfBirth.addingTimeInterval(seconds),
                icon: "location.north.fill", category: .cosmic
            ))
        }
        
        // ═══════════════════════════════════════════
        // MARK: Symmetries & Palindromes
        // ═══════════════════════════════════════════
        
        let quirkyDays: [(Int, String)] = [
            (1_111, "1,111th Day"),
            (5_555, "5,555th Day"),
            (7_777, "7,777th Day"),
            (11_111, "11,111th Day"),
            (12_321, "12,321st Day"),
            (22_222, "22,222nd Day"),
        ]
        for (days, title) in quirkyDays {
            let date = calendar.date(byAdding: .day, value: days, to: dateOfBirth)
            let daysStr = formatNumber(days)
            milestones.append(Milestone(
                id: "quirky.\(days)", title: title,
                subtitle: "A perfectly symmetric \(daysStr) days alive",
                date: date, icon: "sparkles", category: .quirky
            ))
        }
        
        // ═══════════════════════════════════════════
        // MARK: Statistical Life Anchors
        // ═══════════════════════════════════════════
        
        let lifeExpSeconds = expectedLifeYears * secondsPerYear
        
        let anchorMilestones: [(Double, String, String)] = [
            (0.25, "The 25% Mark", "You have conquered your first quarter-century of the statistical human experience."),
            (0.50, "The Halftime Show", "Today marks the exact midpoint of an 80-year statistical life. You've lived half your summers. Make the rest count."),
            (0.75, "The 75% Mark", "Three quarters of the statistical journey complete. The wisdom years begin."),
        ]
        for (fraction, title, subtitle) in anchorMilestones {
            let seconds = lifeExpSeconds * fraction
            milestones.append(Milestone(
                id: "anchor.\(Int(fraction * 100))", title: title,
                subtitle: subtitle,
                date: dateOfBirth.addingTimeInterval(seconds),
                icon: "chart.bar", category: .lifeAnchors
            ))
        }
        
        return milestones.sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
