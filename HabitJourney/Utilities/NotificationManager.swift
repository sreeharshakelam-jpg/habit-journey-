import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isPermissionGranted = false

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { self.isPermissionGranted = granted }
        }
    }

    func scheduleJournalReminder(hour: Int, minute: Int, enabled: Bool) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["hj_journal"])
        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to reflect 📖"
        content.body = "Take a moment to write in your journal and celebrate today's wins."
        content.sound = .default

        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: "hj_journal", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleHabitReminder(for habit: Habit, hour: Int, minute: Int) {
        let identifier = "hj_habit_\(habit.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "\(habit.emoji) Time for \(habit.name)"
        content.body = "Small steps, big results. Keep your streak alive!"
        content.sound = .default

        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelHabitReminder(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["hj_habit_\(habit.id.uuidString)"]
        )
    }
}
