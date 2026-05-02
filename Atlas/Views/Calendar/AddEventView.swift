import SwiftUI
import SwiftData

struct AddEventView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss)      private var dismiss
    @Query(sort: \Subject.name)  private var subjects: [Subject]

    // When non-nil, we're editing an existing event
    var editingEvent: Event? = nil
    var initialDate: Date

    // MARK: - Form state

    @State private var category: EventCategory    = .school

    // School
    @State private var schoolSubType: SchoolSubType = .assignment
    @State private var selectedSubject: String       = ""
    @State private var showNewSubjectField: Bool     = false
    @State private var newSubjectName: String        = ""

    // Work
    @State private var workSubType: WorkSubType = .basketball
    @State private var hourlyRate: Double        = 15.0
    @State private var hasRopero: Bool           = false
    @State private var hasPostres: Bool          = false

    // Other
    @State private var otherTitle: String = ""

    // Timing
    @State private var date:      Date = Date()
    @State private var time:      Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime:   Date = Date()
    @State private var hasTime:   Bool = false   // optional time for Other

    // Notes
    @State private var notes: String = ""

    private var isEditing: Bool { editingEvent != nil }

    // MARK: - Validation

    private var isValid: Bool {
        switch category {
        case .school: return !selectedSubject.isEmpty
        case .work:   return workSubType != .event || endTime > startTime
        case .other:  return !otherTitle.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Category — locked when editing
                if !isEditing {
                    Section {
                        Picker("Category", selection: $category) {
                            ForEach(EventCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // Type-specific fields
                switch category {
                case .school: schoolSection
                case .work:   workSection
                case .other:  otherSection
                }

                // Date
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                // Time
                timingSection

                // Notes
                Section("Notes (optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 70)
                }
            }
            .navigationTitle(isEditing ? "Edit Event" : "New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
        .onAppear(perform: populate)
    }

    // MARK: - Section builders

    @ViewBuilder
    private var schoolSection: some View {
        Section("Type") {
            Picker("Type", selection: $schoolSubType) {
                ForEach(SchoolSubType.allCases, id: \.self) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .pickerStyle(.segmented)
        }

        Section("Subject") {
            ForEach(subjects) { subject in
                Button {
                    selectedSubject = subject.name
                    showNewSubjectField = false
                } label: {
                    HStack {
                        Text(subject.name).foregroundColor(.primary)
                        Spacer()
                        if selectedSubject == subject.name {
                            Image(systemName: "checkmark").foregroundColor(AppColors.accent)
                        }
                    }
                }
            }

            if showNewSubjectField {
                HStack {
                    TextField("Subject name", text: $newSubjectName)
                    Button("Add") { commitNewSubject() }
                        .disabled(newSubjectName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .foregroundColor(AppColors.accent)
                }
            } else {
                Button {
                    showNewSubjectField = true
                } label: {
                    Label("New Subject", systemImage: "plus.circle.fill")
                        .foregroundColor(AppColors.accent)
                }
            }
        }
    }

    @ViewBuilder
    private var workSection: some View {
        Section("Type") {
            Picker("Type", selection: $workSubType) {
                ForEach(WorkSubType.allCases, id: \.self) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .pickerStyle(.segmented)
        }

        if workSubType == .basketball {
            Section("Tags") {
                Toggle(isOn: $hasRopero) {
                    HStack(spacing: 8) {
                        Circle().fill(AppColors.roperoTag).frame(width: 10, height: 10)
                        Text("Ropero")
                    }
                }
                Toggle(isOn: $hasPostres) {
                    HStack(spacing: 8) {
                        Circle().fill(AppColors.postresTag).frame(width: 10, height: 10)
                        Text("Postres")
                    }
                }
            }
        }

        if workSubType == .event {
            Section("Hourly Rate") {
                HStack {
                    Text("Rate (€/h)")
                    Spacer()
                    TextField("0.00", value: $hourlyRate, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }
        }
    }

    @ViewBuilder
    private var otherSection: some View {
        Section("Title") {
            TextField("Event title", text: $otherTitle)
        }
    }

    @ViewBuilder
    private var timingSection: some View {
        switch category {
        case .school:
            Section("Time") {
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
            }
        case .work:
            if workSubType == .event {
                Section("Time") {
                    DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End",   selection: $endTime,   displayedComponents: .hourAndMinute)
                }
            } else {
                Section("Time") {
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }
            }
        case .other:
            Section("Time (optional)") {
                Toggle("Add time", isOn: $hasTime)
                if hasTime {
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }
            }
        }
    }

    // MARK: - Helpers

    private func commitNewSubject() {
        let name = newSubjectName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let s = Subject(name: name)
        modelContext.insert(s)
        selectedSubject = name
        newSubjectName = ""
        showNewSubjectField = false
    }

    private func populate() {
        date = initialDate
        guard let ev = editingEvent else { return }

        category = ev.category
        notes    = ev.notes ?? ""

        switch ev.category {
        case .school:
            schoolSubType   = ev.schoolSubType ?? .assignment
            selectedSubject = ev.subjectName ?? ""
            time            = ev.time ?? Date()
        case .work:
            workSubType = ev.workSubType ?? .basketball
            hasRopero   = ev.hasRopero
            hasPostres  = ev.hasPostres
            hourlyRate  = ev.hourlyRate ?? 15.0
            time        = ev.time ?? Date()
            startTime   = ev.startTime ?? Date()
            endTime     = ev.endTime ?? Date()
        case .other:
            otherTitle = ev.title ?? ""
            if let t = ev.time { time = t; hasTime = true }
        }
        date = ev.date
    }

    private func save() {
        let event: Event
        if let existing = editingEvent {
            event = existing
        } else {
            event = Event(category: category)
            modelContext.insert(event)
        }

        // Reset all type fields before writing
        event.category       = category
        event.date           = date
        event.notes          = notes.isEmpty ? nil : notes
        event.schoolSubType  = nil
        event.subjectName    = nil
        event.workSubType    = nil
        event.hourlyRate     = nil
        event.hasRopero      = false
        event.hasPostres     = false
        event.title          = nil
        event.time           = nil
        event.startTime      = nil
        event.endTime        = nil

        switch category {
        case .school:
            event.schoolSubType = schoolSubType
            event.subjectName   = selectedSubject
            event.time          = time
        case .work:
            event.workSubType = workSubType
            switch workSubType {
            case .basketball:
                event.time      = time
                event.hasRopero  = hasRopero
                event.hasPostres = hasPostres
            case .football:
                event.time = time
            case .event:
                event.startTime  = startTime
                event.endTime    = endTime
                event.hourlyRate = hourlyRate
            }
        case .other:
            event.title = otherTitle
            event.time  = hasTime ? time : nil
        }

        // Re-schedule notifications
        let configs = (try? modelContext.fetch(FetchDescriptor<NotificationConfig>())) ?? []
        NotificationService.shared.scheduleNotifications(for: event, configs: configs)
    }
}
