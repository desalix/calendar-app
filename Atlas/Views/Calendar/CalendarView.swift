import SwiftUI
import SwiftData

struct CalendarView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var allEvents: [Event]

    @State private var vm = CalendarViewModel()

    private let weekHeaders = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                weekdayRow
                Divider()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(Array(vm.daysInMonth().enumerated()), id: \.offset) { _, maybeDate in
                            if let date = maybeDate {
                                DayCellView(
                                    date: date,
                                    events: vm.events(for: date, from: allEvents),
                                    isToday: Calendar.current.isDateInToday(date),
                                    onTapEvent: { vm.selectedEvent = $0 },
                                    onTapDay: { vm.selectedDate = $0; vm.showingAddEvent = true }
                                )
                            } else {
                                Color(UIColor.systemGroupedBackground)
                                    .frame(minHeight: 80)
                            }
                        }
                    }
                    .background(Color(UIColor.separator).opacity(0.3))
                }
                .background(AppColors.background)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $vm.showingAddEvent) {
            AddEventView(initialDate: vm.selectedDate ?? Date())
        }
        .sheet(item: $vm.selectedEvent) { event in
            EventDetailView(event: event)
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(spacing: 0) {
            Text("Atlas")
                .font(.title2.bold())

            Spacer()

            // Month navigation
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

            // Add button
            Button {
                vm.selectedDate = nil
                vm.showingAddEvent = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.accent)
            }
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
                .foregroundColor(enabled ? AppColors.accent : .gray.opacity(0.35))
                .frame(width: 28, height: 28)
        }
        .disabled(!enabled)
    }
}
