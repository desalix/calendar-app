import Foundation
import SwiftUI

@Observable
final class CalendarViewModel {

    // MARK: - State
    var currentDate: Date = Date()
    var selectedDate: Date? = nil
    var selectedEvent: Event? = nil
    var showingAddEvent: Bool = false

    // MARK: - Navigation bounds
    // Earliest navigable month: January 2026
    private let minMonth: Date = {
        Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1))!
    }()

    // Latest navigable month: 1 full year from today
    private var maxMonth: Date {
        Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    }

    var canGoBack: Bool {
        firstOfMonth(currentDate) > firstOfMonth(minMonth)
    }

    var canGoForward: Bool {
        firstOfMonth(currentDate) < firstOfMonth(maxMonth)
    }

    var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: currentDate)
    }

    // MARK: - Navigation

    func goToPreviousMonth() {
        guard canGoBack else { return }
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
    }

    func goToNextMonth() {
        guard canGoForward else { return }
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
    }

    // MARK: - Grid

    /// Returns 42 slots (6 rows × 7 cols, Mon-first). nil = empty padding cell.
    func daysInMonth() -> [Date?] {
        let cal = Calendar.current
        let first = firstOfMonth(currentDate)
        let range = cal.range(of: .day, in: .month, for: first)!

        // weekday 1=Sun … 7=Sat → convert to Mon-first offset (Mon=0 … Sun=6)
        let rawWeekday = cal.component(.weekday, from: first)
        let offset = (rawWeekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            days.append(cal.date(byAdding: .day, value: day - 1, to: first)!)
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    func events(for date: Date, from all: [Event]) -> [Event] {
        let cal = Calendar.current
        return all
            .filter { cal.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    // MARK: - Helpers

    private func firstOfMonth(_ date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: date))!
    }
}
