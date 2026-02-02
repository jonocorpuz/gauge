import UserNotifications
import Foundation

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    private struct TimeConst {
        static let secondsInDay: TimeInterval = 86_400
        static let secondsInWeek: TimeInterval = 604_800
        static let sevenDayInterval: TimeInterval = 7
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("DEBUG: Notifications enabled")
            }
            
            else if let error = error {
                print("DEBUG: Notification error: \(error.localizedDescription)")
            }
        }
    }

    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    
    func rescheduleAllNotifications(items: [MaintenanceItem], currentMileage: Int, dailyRate: Double) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        scheduleInactivityNudge()
        
        var rate = dailyRate
        if rate == 0 { rate = 50.0 }
        
        if rate > 0 {
            for item in items where item.type == .maintenance {
                schedulePredictiveItem(item, currentMileage: currentMileage, dailyRate: rate)
            }
        }
    }
    
    private func scheduleInactivityNudge() {
        scheduleNotification(
            id: "inactivity_nudge",
            title: "Update your Odometer",
            body: "It's been a week! Update your mileage to keep predictions accurate.",
            timeInterval: TimeConst.secondsInWeek
        )
    }
    
    private func schedulePredictiveItem(_ item: MaintenanceItem, currentMileage: Int, dailyRate: Double) {
        let remainingKm = Double(item.intervalMileage - (currentMileage % item.intervalMileage))
        let daysUntilDue = remainingKm / dailyRate
        let secondsUntilDue = daysUntilDue * TimeConst.secondsInDay
        
        if secondsUntilDue <= 0 {
            // Overdue (or due right now)
            // We schedule it for 1 second in the future so it triggers immediately
            scheduleNotification(
                id: "due_\(item.id)",
                title: "Service Overdue: \(item.title)",
                body: "This item is overdue, service immediately!",
                timeInterval: 1
            )
        }
        
        else {
            // Due in the Future
            // Schedule the exact due date
            scheduleNotification(
                id: "due_\(item.id)",
                title: "Service Due: \(item.title)",
                body: "Based on your driving, this service may be due today.",
                timeInterval: secondsUntilDue
            )
            
            // Schedule the "1 Week Warning"
            let warningTime = secondsUntilDue - TimeConst.secondsInWeek
            if warningTime > 0 {
                scheduleNotification(
                    id: "warn_\(item.id)",
                    title: "Upcoming: \(item.title)",
                    body: "Based on your driving,this service is due in less than a week.",
                    timeInterval: warningTime
                )
            }
        }
    }

    private func scheduleNotification(id: String, title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let safeTime = max(timeInterval, 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: safeTime, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleDebugNotifications() {
        print("DEBUG: Scheduling test notifications...")
        
        scheduleNotification(
            id: "debug_update",
            title: "Update your Odometer",
            body: "It's been a week! Update your mileage to keep predictions accurate.",
            timeInterval: 1
        )
        
        scheduleNotification(
            id: "debug_soon",
            title: "Upcoming: Debug Item",
            body: "You will likely need this service in about a week.",
            timeInterval: 9
        )
        
        scheduleNotification(
            id: "debug_due",
            title: "Service Due: Debug Item",
            body: "Based on your driving, this service is due today.",
            timeInterval: 17
        )
    }
}
