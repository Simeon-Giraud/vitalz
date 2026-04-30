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

/// A data model containing specific future date milestones.
public struct LifeMilestones {
    public let tenThousandthDay: Date?
    public let oneBillionthSecond: Date
    public let fiveHundredMillionthHeartbeat: Date
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
    private let averagePhoneHoursPerDay = 3.0
    private let averageCoffeeLitersPerDay = 0.25
    private let caffeineStartAgeYears = 15.0
    
    /// Initialize with a specific Date of Birth.
    public init(dateOfBirth: Date) {
        self.dateOfBirth = dateOfBirth
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
    
    /// Calculates specific milestone dates based on the date of birth.
    ///
    /// - Returns: A `LifeMilestones` model containing the calculated milestone dates.
    public func calculateMilestones() -> LifeMilestones {
        let calendar = Calendar.current
        
        // 1. The 10,000th day alive
        let tenThousandthDay = calendar.date(byAdding: .day, value: 10_000, to: dateOfBirth)
        
        // 2. The 1 billionth second alive
        let oneBillionSeconds: TimeInterval = 1_000_000_000
        let oneBillionthSecond = dateOfBirth.addingTimeInterval(oneBillionSeconds)
        
        // 3. The 500,000,000th heartbeat
        // Based on 70 beats per minute. Time = Total Beats / Beats per Second
        let beatsPerSecond = Double(heartbeatsPerMinute) / 60.0
        let secondsForMilestone = 500_000_000.0 / beatsPerSecond
        let fiveHundredMillionthHeartbeat = dateOfBirth.addingTimeInterval(secondsForMilestone)
        
        return LifeMilestones(
            tenThousandthDay: tenThousandthDay,
            oneBillionthSecond: oneBillionthSecond,
            fiveHundredMillionthHeartbeat: fiveHundredMillionthHeartbeat
        )
    }
}
