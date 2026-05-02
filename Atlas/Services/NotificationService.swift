import UserNotifications
import Foundation

final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    // MARK: - Schedule

    func scheduleNotifications(for event: Event, configs: [NotificationConfig]) {
        cancelNotifications(for: event)

        let eventType = notifType(for: event)
        let relevant  = configs.filter { $0.eventType == eventType && $0.isEnabled }

        for config in relevant {
            guard let fireDate = fireDate(for: event, timing: config.timing),
                  fireDate > Date() else { continue }
            schedule(event: event, at: fireDate, index: config.reminderIndex, timing: config.timing)
        }
    }

    // MARK: - Cancel

    func cancelNotifications(for event: Event) {
        let ids = (0..<3).map { "\(event.id.uuidString)-notif-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Private

    private func schedule(event: Event, at date: Date, index: Int, timing: NotificationTiming) {
        let content        = UNMutableNotificationContent()
        content.title      = event.displayTitle
        content.body       = bodyText(for: event, timing: timing)
        content.sound      = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: date
        )
        let trigger    = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request    = UNNotificationRequest(
            identifier: "\(event.id.uuidString)-notif-\(index)",
            content:    content,
            trigger:    trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func fireDate(for event: Event, timing: NotificationTiming) -> Date? {
        // Determine the base datetime of the event
        let cal  = Calendar.current
        var base: Date

        if let t = event.time {
            var c = cal.dateComponents([.year, .month, .day], from: event.date)
            let tc = cal.dateComponents([.hour, .minute], from: t)
            c.hour = tc.hour; c.minute = tc.minute
            base = cal.date(from: c) ?? event.date
        } else if let s = event.startTime {
            var c = cal.dateComponents([.year, .month, .day], from: event.date)
            let tc = cal.dateComponents([.hour, .minute], from: s)
            c.hour = tc.hour; c.minute = tc.minute
            base = cal.date(from: c) ?? event.date
        } else {
            // All-day: notify at 09:00 on the event date
            var c = cal.dateComponents([.year, .month, .day], from: event.date)
            c.hour = 9; c.minute = 0
            base = cal.date(from: c) ?? event.date
        }

        return base.addingTimeInterval(-timing.secondsBefore)
    }

    private func bodyText(for event: Event, timing: NotificationTiming) -> String {
        switch timing {
        case .atTime:     return "Starting now"
        case .fifteenMin: return "In 15 minutes"
        case .thirtyMin:  return "In 30 minutes"
        case .oneHour:    return "In 1 hour"
        case .twoHours:   return "In 2 hours"
        case .oneDay:     return "Tomorrow"
        case .twoDays:    return "In 2 days"
        case .oneWeek:    return "In 1 week"
        }
    }

    private func notifType(for event: Event) -> NotificationEventType {
        switch event.category {
        case .school:
            return event.schoolSubType == .exam ? .exam : .assignment
        case .work:
            switch event.workSubType {
            case .basketball: return .basketball
            case .football:   return .football
            case .event:      return .event
            case nil:         return .other
            }
        case .other:
            return .other
        }
    }
}
