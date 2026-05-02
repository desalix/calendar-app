import Foundation
import SwiftData

// MARK: ─────────────────────────────────────────────────────────────────────
// AI SERVICE
//
// Placeholder implementation.
// Replace the body of `callModel(messages:)` with a real API call
// (e.g. Anthropic Claude, OpenAI) to activate the assistant.
//
// The `respond(to:events:context:)` method already:
//   • builds a calendar context string from all events
//   • passes it as a system message so the model can read the DB
//   • exposes `context` so helper methods can create / edit / delete events
// ─────────────────────────────────────────────────────────────────────────

final class AIService {

    static let shared = AIService()
    private init() {}

    // MARK: - Public entry point

    func respond(to userMessage: String, events: [Event], context: ModelContext) async -> String {
        let systemPrompt = buildSystemPrompt(events: events)
        let messages: [[String: String]] = [
            ["role": "system",    "content": systemPrompt],
            ["role": "user",      "content": userMessage]
        ]

        // TODO: replace with real model call
        return await callModel(messages: messages, context: context)
    }

    // MARK: - Model call (stub → replace)

    /// Replace this method body with your actual API request.
    /// `context` is passed through so the model can call helper methods
    /// to create, update or delete calendar entries.
    private func callModel(messages: [[String: String]], context: ModelContext) async -> String {
        // ── PLACEHOLDER ──────────────────────────────────────────────────
        // Simulate a short network delay so the typing indicator is visible.
        try? await Task.sleep(nanoseconds: 600_000_000)
        return "Chat works properly, this is a test."
        // ─────────────────────────────────────────────────────────────────

        // TODO: real implementation example (Anthropic Claude):
        //
        // guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
        //     return "Configuration error."
        // }
        // var request = URLRequest(url: url)
        // request.httpMethod = "POST"
        // request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        //
        // let body: [String: Any] = [
        //     "model": "claude-sonnet-4-6",
        //     "max_tokens": 1024,
        //     "system": messages.first(where: { $0["role"] == "system" })?["content"] ?? "",
        //     "messages": messages.filter { $0["role"] != "system" }
        // ]
        // request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        // let (data, _) = try await URLSession.shared.data(for: request)
        // // parse response…
    }

    // MARK: - System prompt builder

    private func buildSystemPrompt(events: [Event]) -> String {
        let cal = Calendar.current
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short

        var lines = [
            "You are Atlas, a personal calendar assistant.",
            "Today is \(fmt.string(from: Date())).",
            "",
            "The user's upcoming calendar entries (next 60 days):"
        ]

        let upcoming = events.filter {
            $0.date >= cal.startOfDay(for: Date()) &&
            $0.date <= Date().addingTimeInterval(60 * 86_400)
        }
        .sorted { $0.date < $1.date }

        if upcoming.isEmpty {
            lines.append("  (none)")
        } else {
            for ev in upcoming {
                var line = "• \(fmt.string(from: ev.date)) — \(ev.displayTitle)"
                if let subject = ev.subjectName { line += " (\(subject))" }
                if let earnings = ev.earnings    { line += " [€\(String(format: "%.0f", earnings))]" }
                lines.append(line)
            }
        }

        lines += [
            "",
            "Answer helpfully and concisely. You can reference the calendar entries above.",
            "Do not invent entries that are not listed."
        ]

        return lines.joined(separator: "\n")
    }

    // MARK: - DB helpers (called when AI is wired up with function-calling)

    func createEvent(
        category: EventCategory,
        date: Date,
        schoolSubType: SchoolSubType? = nil,
        subjectName: String? = nil,
        workSubType: WorkSubType? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        time: Date? = nil,
        hourlyRate: Double? = nil,
        title: String? = nil,
        notes: String? = nil,
        context: ModelContext
    ) -> Event {
        let event = Event(category: category, date: date, notes: notes)
        event.schoolSubType = schoolSubType
        event.subjectName   = subjectName
        event.workSubType   = workSubType
        event.startTime     = startTime
        event.endTime       = endTime
        event.time          = time
        event.hourlyRate    = hourlyRate
        event.title         = title
        context.insert(event)
        return event
    }

    func updateEvent(_ event: Event, date: Date? = nil, notes: String? = nil, time: Date? = nil) {
        if let d = date  { event.date  = d }
        if let n = notes { event.notes = n }
        if let t = time  { event.time  = t }
    }

    func deleteEvent(_ event: Event, context: ModelContext) {
        NotificationService.shared.cancelNotifications(for: event)
        context.delete(event)
    }

    func queryEvents(on date: Date, from events: [Event]) -> [Event] {
        let cal = Calendar.current
        return events.filter { cal.isDate($0.date, inSameDayAs: date) }
    }
}
