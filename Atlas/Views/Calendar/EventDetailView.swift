import SwiftUI
import SwiftData

struct EventDetailView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss)      private var dismiss

    let event: Event

    @State private var showingEdit   = false
    @State private var showingDelete = false

    private var color: Color { AppColors.color(for: event.eventColor) }

    private let dateFmt: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .long; return f
    }()
    private let timeFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Color accent bar
                    color.frame(height: 5)

                    VStack(alignment: .leading, spacing: 18) {
                        // Title block
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.displayTitle)
                                .font(.title.bold())

                            if let subject = event.subjectName {
                                Text(subject)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }

                            // Category badge
                            Text(event.category.rawValue)
                                .font(.caption.bold())
                                .foregroundColor(color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(color.opacity(0.12))
                                .cornerRadius(6)
                        }

                        Divider()

                        // Date
                        row(icon: "calendar",
                            label: "Date",
                            value: dateFmt.string(from: event.date))

                        // Time
                        if let t = event.time {
                            row(icon: "clock",
                                label: "Time",
                                value: timeFmt.string(from: t))
                        }
                        if let s = event.startTime, let e = event.endTime {
                            row(icon: "clock",
                                label: "Time",
                                value: "\(timeFmt.string(from: s)) – \(timeFmt.string(from: e))")
                        }

                        // Pay (work only)
                        if event.category == .work, let earnings = event.earnings {
                            row(icon: "eurosign.circle",
                                label: "Pay",
                                value: String(format: "%.2f €", earnings))
                        }
                        if let rate = event.hourlyRate {
                            row(icon: "eurosign",
                                label: "Hourly rate",
                                value: String(format: "%.2f €/h", rate))
                        }

                        // Basketball tags
                        if event.workSubType == .basketball, event.hasRopero || event.hasPostres {
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                sectionLabel("Tags")
                                if event.hasRopero  { tagRow("Ropero",  AppColors.roperoTag)  }
                                if event.hasPostres { tagRow("Postres", AppColors.postresTag) }
                            }
                        }

                        // Notes
                        if let notes = event.notes, !notes.isEmpty {
                            Divider()
                            VStack(alignment: .leading, spacing: 6) {
                                sectionLabel("Notes")
                                Text(notes).font(.body)
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button { showingEdit = true } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) { showingDelete = true } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEventView(editingEvent: event, initialDate: event.date)
        }
        .confirmationDialog("Delete this event?", isPresented: $showingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                NotificationService.shared.cancelNotifications(for: event)
                modelContext.delete(event)
                dismiss()
            }
        }
    }

    // MARK: - Sub-components

    private func row(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.accent)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(.secondary)
                Text(value).font(.body)
            }
        }
    }

    private func tagRow(_ name: String, _ dotColor: Color) -> some View {
        HStack(spacing: 8) {
            Circle().fill(dotColor).frame(width: 10, height: 10)
            Text(name).font(.body)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.bold())
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }
}
