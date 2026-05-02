import SwiftData
import Foundation

// MARK: - Enums

enum EventCategory: String, Codable, CaseIterable {
    case school = "School"
    case work   = "Work"
    case other  = "Other"
}

enum SchoolSubType: String, Codable, CaseIterable {
    case assignment = "Assignment"
    case exam       = "Exam"
}

enum WorkSubType: String, Codable, CaseIterable {
    case basketball = "Basketball"
    case football   = "Football"
    case event      = "Event"
}

// MARK: - Model

@Model
final class Event {
    var id: UUID = UUID()

    // Category
    var categoryRaw: String = EventCategory.school.rawValue
    var category: EventCategory {
        get { EventCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    // School
    var schoolSubTypeRaw: String?
    var schoolSubType: SchoolSubType? {
        get { schoolSubTypeRaw.flatMap { SchoolSubType(rawValue: $0) } }
        set { schoolSubTypeRaw = newValue?.rawValue }
    }
    var subjectName: String?

    // Work
    var workSubTypeRaw: String?
    var workSubType: WorkSubType? {
        get { workSubTypeRaw.flatMap { WorkSubType(rawValue: $0) } }
        set { workSubTypeRaw = newValue?.rawValue }
    }
    var hourlyRate: Double?
    var hasRopero: Bool = false
    var hasPostres: Bool = false

    // Other
    var title: String?

    // Timing
    var date: Date = Date()
    var time: Date?        // School, Basketball, Football, Other
    var startTime: Date?   // Work Event
    var endTime: Date?     // Work Event

    // Optional
    var notes: String?
    var createdAt: Date = Date()

    init(
        category: EventCategory,
        date: Date = Date(),
        notes: String? = nil
    ) {
        self.id = UUID()
        self.categoryRaw = category.rawValue
        self.date = date
        self.notes = notes
        self.createdAt = Date()
    }

    // MARK: - Computed

    var displayTitle: String {
        switch category {
        case .school: return schoolSubType?.rawValue ?? "School"
        case .work:   return workSubType?.rawValue ?? "Work"
        case .other:  return title ?? "Event"
        }
    }

    var earnings: Double? {
        switch workSubType {
        case .basketball, .football:
            return 40.0
        case .event:
            guard let s = startTime, let e = endTime, let r = hourlyRate else { return nil }
            let hours = e.timeIntervalSince(s) / 3600.0
            return max(0, hours) * r
        case nil:
            return nil
        }
    }

    var eventColor: AppColor {
        switch category {
        case .school:
            return schoolSubType == .exam ? .exam : .assignment
        case .work:
            switch workSubType {
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

// Lightweight token so views can resolve color without importing AppColors everywhere
enum AppColor {
    case assignment, exam, basketball, football, event, other
}
