import Foundation
import UserNotifications

/// Manages local push notifications for user milestones
public class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()
    
    @Published public var hasPermission = false
    
    private init() {}
    
    /// Request permissions for local notifications
    public func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.hasPermission = granted
            }
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }
    }
    
    /// Schedules a milestone notification at the exact date.
    public func scheduleMilestoneNotification(title: String, body: String, date: Date, identifier: String) {
        // Only schedule if the date is actually in the future
        guard date > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Match the exact day, month, year, hour, and minute
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification \(identifier): \(error)")
            } else {
                print("Successfully scheduled \(identifier) for \(date)")
            }
        }
    }
    
    /// Clears any previously tracked milestones if the user resets their identity.
    public func clearAllMilestoneNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
