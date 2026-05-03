import SwiftUI
import SwiftData

struct IncomeView: View {

    @EnvironmentObject var theme: ColorTheme
    @Query private var allEvents: [Event]
    @State private var currentMonth: Date = Date()

    private let cal = Calendar.current

    // Navigation bounds (mirror CalendarView)
    private var minMonth: Date { cal.date(from: DateComponents(year: 2026, month: 1))! }
    private var maxMonth: Date { cal.date(byAdding: .year, value: 1, to: Date())! }

    private var canGoBack: Bool    { firstOf(currentMonth) > firstOf(minMonth) }
    private var canGoForward: Bool { firstOf(currentMonth) < firstOf(maxMonth) }

    private var workEntries: [Event] {
        allEvents
            .filter { $0.category == .work && cal.isDate($0.date, equalTo: currentMonth, toGranularity: .month) }
            .sorted { $0.date < $1.date }
    }

    private var totalIncome: Double {
        workEntries.compactMap(\.earnings).reduce(0, +)
    }

    private var monthTitle: String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"
        return f.string(from: currentMonth)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    monthPicker
                    totalCard
                    if workEntries.isEmpty {
                        emptyState
                    } else {
                        entriesList
                    }
                }
                .padding(16)
            }
            .background(theme.background)
            .navigationTitle("Income")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Month picker

    private var monthPicker: some View {
        HStack {
            navBtn(icon: "chevron.left", enabled: canGoBack) {
                currentMonth = cal.date(byAdding: .month, value: -1, to: currentMonth)!
            }
            Spacer()
            Text(monthTitle).font(.headline)
            Spacer()
            navBtn(icon: "chevron.right", enabled: canGoForward) {
                currentMonth = cal.date(byAdding: .month, value: 1, to: currentMonth)!
            }
        }
    }

    // MARK: - Total card

    private var totalCard: some View {
        VStack(spacing: 6) {
            Text("This month's income")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f €", totalIncome))
                .font(.system(size: 46, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
    }

    // MARK: - List

    private var entriesList: some View {
        VStack(spacing: 10) {
            ForEach(workEntries) { event in
                IncomeEntryRow(event: event)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "eurosign.circle")
                .font(.system(size: 44))
                .foregroundColor(.secondary.opacity(0.3))
            Text("No work entries this month.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(50)
    }

    // MARK: - Helpers

    private func firstOf(_ date: Date) -> Date {
        cal.date(from: cal.dateComponents([.year, .month], from: date))!
    }

    private func navBtn(icon: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3.bold())
                .foregroundColor(enabled ? theme.accent : .gray.opacity(0.3))
        }
        .disabled(!enabled)
    }
}

// MARK: - Entry row

struct IncomeEntryRow: View {

    @EnvironmentObject var theme: ColorTheme
    let event: Event

    private var color: Color   { theme.color(for: event.eventColor) }
    private var earnings: String {
        guard let e = event.earnings else { return "—" }
        return String(format: "%.2f €", e)
    }

    private let dateFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "d MMM"; return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            // Accent bar
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.displayTitle)
                    .font(.headline)
                Text(dateFmt.string(from: event.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(earnings)
                .font(.headline)
        }
        .padding(14)
        .background(color.opacity(0.10))
        .cornerRadius(14)
    }
}
