import SwiftUI
import SwiftData

struct SubjectsSettingsView: View {

    @EnvironmentObject var theme: ColorTheme
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subject.name)  private var subjects: [Subject]
    @Query private var allEvents: [Event]

    @State private var showingAdd   = false
    @State private var newName      = ""
    @State private var deleteError  = false
    @State private var errorMessage = ""

    var body: some View {
        List {
            ForEach(subjects) { subject in
                HStack {
                    // Subjects logo icon
                    Image(systemName: "book.closed.fill")
                        .font(.caption)
                        .foregroundColor(theme.accent)
                        .frame(width: 20)

                    Text(subject.name)

                    Spacer()

                    if isInUse(subject) {
                        Text("In use")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: attemptDelete)

            if showingAdd {
                HStack {
                    TextField("New subject name", text: $newName)
                        .onSubmit { commitAdd() }
                    Button("Add", action: commitAdd)
                        .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .foregroundColor(theme.accent)
                }
            }
        }
        .navigationTitle("Subjects")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation { showingAdd.toggle() }
                    if !showingAdd { newName = "" }
                } label: {
                    Image(systemName: showingAdd ? "xmark.circle.fill" : "plus.circle.fill")
                        .foregroundColor(theme.accent)
                }
            }
        }
        .alert("Cannot Delete", isPresented: $deleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Helpers

    private func isInUse(_ subject: Subject) -> Bool {
        allEvents.contains { $0.subjectName == subject.name }
    }

    private func commitAdd() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        // Avoid duplicates (case-insensitive)
        guard !subjects.contains(where: { $0.name.lowercased() == name.lowercased() }) else {
            newName = ""
            showingAdd = false
            return
        }
        modelContext.insert(Subject(name: name))
        newName = ""
        showingAdd = false
    }

    private func attemptDelete(at offsets: IndexSet) {
        for index in offsets {
            let subject = subjects[index]
            if isInUse(subject) {
                errorMessage = "\"\(subject.name)\" is used by existing entries and cannot be deleted."
                deleteError = true
            } else {
                modelContext.delete(subject)
            }
        }
    }
}
