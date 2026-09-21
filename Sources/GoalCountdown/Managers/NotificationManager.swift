import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }

    func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "GoalCountdown ⏰"
        content.sound = .default

        let goal = DataManager.shared.loadGoal()

        if let goal = goal {
            content.body = "\(goal.daysRemaining) days left! 💪 ₹\(Int(goal.targetAmount - DataManager.shared.totalRevenue())) more to go. Show up today!"
        } else {
            content.body = "Don't break the chain! Check in today and keep pushing toward your goal."
        }

        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "daily-reminder",
            content: content,
            trigger: trigger
        )

        center.add(request)

        // Evening check-in reminder
        let eveningContent = UNMutableNotificationContent()
        eveningContent.title = "Evening Reflection 🌙"
        eveningContent.sound = .default
        eveningContent.body = "What did you accomplish today? Write in your journal!"

        var eveningComponents = DateComponents()
        eveningComponents.hour = 20
        eveningComponents.minute = 0

        let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: eveningComponents, repeats: true)
        let eveningRequest = UNNotificationRequest(
            identifier: "evening-journal",
            content: eveningContent,
            trigger: eveningTrigger
        )

        center.add(eveningRequest)
    }

    func sendStreakNotification(streak: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 \(streak)-Day Streak!"
        content.body = "Incredible! \(streak) days in a row. Don't stop now!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "streak-\(streak)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendMilestoneNotification(_ message: String) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 Milestone Unlocked!"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "milestone-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
