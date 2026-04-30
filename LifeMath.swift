import Foundation

/// A data model containing current life statistics.
public struct LifeStats {
    public let totalDaysAlive: Int
    public let totalSecondsAlive: Int
    public let estimatedTotalHeartbeats: Int
    public let estimatedHoursSlept: Double
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
        // Using average year length (365.25 days) to account for leap years over 80 years
        let lifeExpectancySeconds = expectedLifeYears * 365.25 * 24.0 * 60.0 * 60.0
        let percentage = (Double(totalSecondsAlive) / lifeExpectancySeconds) * 100.0
        let percentageOf80YearLifeExpectancy = max(0.0, percentage) 
        
        return LifeStats(
            totalDaysAlive: totalDaysAlive,
            totalSecondsAlive: totalSecondsAlive,
            estimatedTotalHeartbeats: estimatedTotalHeartbeats,
            estimatedHoursSlept: estimatedHoursSlept,
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
