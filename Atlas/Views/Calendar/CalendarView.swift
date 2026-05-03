import SwiftUI
import SwiftData

struct CalendarView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var allEvents: [Event]

    @EnvironmentObject var theme: ColorTheme
    @State private var vm = CalendarViewModel()

    private let weekHeaders = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        VStack(spacing: 0) {
            header
            weekdayRow
            Divider()

            let days = vm.daysInMonth()
            let rowCount = max(1, days.count / 7)

            VStack(spacing: 1) {
                ForEach(0..<rowCount, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<7, id: \.self) { col in
                            let idx = row * 7 + col
                            if idx < days.count, let date = days[idx] {
                                DayCellView(
                                    date: date,
                                    events: vm.events(for: date, from: allEvents),
                                    isToday: Calendar.current.isDateInToday(date),
                                    onTapEvent: { vm.selectedEvent = $0 },
                                    onTapDay: { vm.selectedDate = $0; vm.showingAddEvent = true }
                                )
                            } else {
                                Color(UIColor.systemGroupedBackground)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.separator).opacity(0.3))
        }
        .sheet(isPresented: $vm.showingAddEvent) {
            AddEventView(initialDate: vm.selectedDate ?? Date())
                .interactiveDismissDisabled()
        }
        .sheet(item: $vm.selectedEvent) { event in
            EventDetailView(event: event)
                .interactiveDismissDisabled()
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(spacing: 0) {
            Text("Atlas")
                .font(.title2.bold())

            Spacer()

            HStack(spacing: 6) {
                navButton(systemImage: "chevron.left", enabled: vm.canGoBack) {
                    vm.goToPreviousMonth()
                }
                Text(vm.monthTitle)
                    .font(.subheadline.weight(.semibold))
                    .frame(minWidth: 120)
                navButton(systemImage: "chevron.right", enabled: vm.canGoForward) {
                    vm.goToNextMonth()
                }
            }

            Spacer()

            Button {
                vm.selectedDate = nil
                vm.showingAddEvent = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(theme.accent)
            }
            .accessibilityLabel("Add Event")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
    }

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(weekHeaders, id: \.self) { day in
                Text(day)
                    .font(.caption2.bold())
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 6)
        .background(Color.white)
    }

    private func navButton(systemImage: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.caption.bold())
                .foregroundColor(enabled ? theme.accent : .gray.opacity(0.35))
                .frame(width: 28, height: 28)
        }
        .disabled(!enabled)
    }
}

