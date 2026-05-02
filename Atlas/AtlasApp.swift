import SwiftUI
import SwiftData

@main
struct AtlasApp: App {

    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Event.self,
                Subject.self,
                ChatMessage.self,
                NotificationConfig.self
            ])
            modelContainer = try ModelContainer(for: schema)
            seedIfNeeded(context: modelContainer.mainContext)
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }

        // Request notification permission on first launch
        NotificationService.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .preferredColorScheme(.light)
        }
    }

    // MARK: - One-time seed

    private func seedIfNeeded(context: ModelContext) {
        seedSubjects(context: context)
        seedNotificationConfigs(context: context)
    }

    private func seedSubjects(context: ModelContext) {
        let descriptor = FetchDescriptor<Subject>()
        guard let existing = try? context.fetch(descriptor), existing.isEmpty else { return }

        let defaults = [
            "Algebra", "Bases de Datos", "Calculo", "Concurrencia",
            "Contabilidad", "Discreta", "Econometria", "Fisica",
            "Fundamentos", "Macro", "Sistemas"
        ]
        defaults.forEach { context.insert(Subject(name: $0, isDefault: true)) }
        try? context.save()
    }

    private func seedNotificationConfigs(context: ModelContext) {
        let descriptor = FetchDescriptor<NotificationConfig>()
        guard let existing = try? context.fetch(descriptor), existing.isEmpty else { return }

        for eventType in NotificationEventType.allCases {
            for index in 0..<3 {
                context.insert(NotificationConfig(eventType: eventType, reminderIndex: index))
            }
        }
        try? context.save()
    }
}
