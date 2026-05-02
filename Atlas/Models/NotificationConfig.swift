import SwiftData
import Foundation

enum NotificationEventType: String, Codable, CaseIterable {
    case assignment = "Assignment"
    case exam       = "Exam"
    case basketball = "Basketball"
    case football   = "Football"
    case event      = "Event"
    case other      = "Other"
}

enum NotificationTiming: String, Codable, CaseIterable {
    case atTime         = "At time of event"
    case fifteenMin     = "15 minutes before"
    case thirtyMin      = "30 minutes before"
    case oneHour        = "1 hour before"
    case twoHours       = "2 hours before"
    case oneDay         = "1 day before"
    case twoDays        = "2 days before"
    case oneWeek        = "1 week before"

    var secondsBefore: TimeInterval {
        switch self {
        case .atTime:     return 0
        case .fifteenMin: return 15 * 60
        case .thirtyMin:  return 30 * 60
        case .oneHour:    return 3_600
        case .twoHours:   return 7_200
        case .oneDay:     return 86_400
        case .twoDays:    return 172_800
        case .oneWeek:    return 604_800
        }
    }
}

@Model
final class NotificationConfig {
    var id: UUID = UUID()
    var eventTypeRaw: String = NotificationEventType.assignment.rawValue
    var eventType: NotificationEventType {
        get { NotificationEventType(rawValue: eventTypeRaw) ?? .other }
        set { eventTypeRaw = newValue.rawValue }
    }
    var reminderIndex: Int = 0   // 0, 1, or 2 — up to 3 per event type
    var isEnabled: Bool = false
    var timingRaw: String = NotificationTiming.oneDay.rawValue
    var timing: NotificationTiming {
        get { NotificationTiming(rawValue: timingRaw) ?? .oneDay }
        set { timingRaw = newValue.rawValue }
    }

    init(eventType: NotificationEventType, reminderIndex: Int, isEnabled: Bool = false, timing: NotificationTiming = .oneDay) {
        self.id = UUID()
        self.eventTypeRaw = eventType.rawValue
        self.reminderIndex = reminderIndex
        self.isEnabled = isEnabled
        self.timingRaw = timing.rawValue
    }
}
