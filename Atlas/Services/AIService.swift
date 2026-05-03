import Foundation
import SwiftData

final class AIService {

    static let shared = AIService()
    private init() {}

    // MARK: - Entry point

    func respond(history: [ChatMessage], events: [Event], context: ModelContext) async -> String {
        guard let apiKey = KeychainHelper.apiKey, !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "No API key configured. Go to Settings → AI and paste your Gemini API key."
        }
        return await callGemini(history: history, events: events, apiKey: apiKey)
    }

    // MARK: - Gemini API

    private func callGemini(history: [ChatMessage], events: [Event], apiKey: String) async -> String {
        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: endpoint) else { return "Configuration error." }

        let body: [String: Any] = [
            "system_instruction": [
                "parts": [["text": buildSystemPrompt(events: events)]]
            ],
            "contents": history.map { msg -> [String: Any] in
                ["role":  msg.isUser ? "user" : "model",
                 "parts": [["text": msg.content]]]
            },
            "generationConfig": [
                "maxOutputTokens": 400,
                "temperature":     0.3
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let raw = String(data: data, encoding: .utf8) ?? ""
                if http.statusCode == 400 { return "Invalid API key or request." }
                if http.statusCode == 429 { return "Rate limit reached. Try again in a moment." }
                return "API error \(http.statusCode): \(raw.prefix(120))"
            }

            return parseResponse(data) ?? "The model returned an empty response."
        } catch {
            return "Network error: \(error.localizedDescription)"
        }
    }

    private func parseResponse(_ data: Data) -> String? {
        guard
            let json       = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = json["candidates"] as? [[String: Any]],
            let content    = candidates.first?["content"] as? [String: Any],
            let parts      = content["parts"] as? [[String: Any]],
            let text       = parts.first?["text"] as? String
        else { return nil }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - System prompt

    private func buildSystemPrompt(events: [Event]) -> String {
        let dateFmt = DateFormatter()
        dateFmt.dateStyle = .medium
        dateFmt.timeStyle = .short

        let cal      = Calendar.current
        let today    = cal.startOfDay(for: Date())
        let in60days = Date().addingTimeInterval(60 * 86_400)

        // Build calendar data block
        let upcoming = events
            .filter { $0.date >= today && $0.date <= in60days }
            .sorted { $0.date < $1.date }

        var calendarLines: [String]
        if upcoming.isEmpty {
            calendarLines = ["(no entries in the next 60 days)"]
        } else {
            calendarLines = upcoming.map { ev in
                var line = "• \(dateFmt.string(from: ev.date)) — \(ev.displayTitle)"
                if let subject  = ev.subjectName { line += " [\(subject)]" }
                if let earnings = ev.earnings    { line += " [€\(String(format: "%.2f", earnings))]" }
                if ev.hasRopero  { line += " [Ropero]" }
                if ev.hasPostres { line += " [Postres]" }
                return line
            }
        }

        let calendarData = calendarLines.joined(separator: "\n")
        let todayStr     = dateFmt.string(from: Date())

        return """
        You are Atlas, a personal calendar secretary app. Your sole purpose is to help the user manage their schedule and income — nothing else.

        ## Hard rules (never break these)
        - You are a SECRETARY. Refuse any request outside calendar, scheduling, or income topics. If asked, say: "I'm only here to help with your calendar and income."
        - Only do exactly what is asked. Do not volunteer, create, suggest, or produce anything beyond the direct answer.
        - If the user asks HOW to do something, explain it. Do not do it for them unless they explicitly say "do it", "add it", "create it", "edit it", etc.
        - Never assume intent. If unclear, ask one short clarifying question.

        ## What you can do
        - Read, summarize, and answer questions about the user's calendar events.
        - Add, edit, or delete events when explicitly instructed.
        - Calculate and report income from work entries (basketball, football, paid events).
        - Answer scheduling questions ("am I free on Thursday?", "what do I have this week?").

        ## Response style
        - Be extremely concise. One to three sentences maximum unless a list is genuinely needed.
        - Never explain what you're about to do — just do it.
        - Never add filler phrases ("Great question!", "Of course!", "Sure!").
        - If the answer is a number or a yes/no, lead with that.

        ## Context
        Today is \(todayStr).
        The user's calendar entries for the next 60 days:

        \(calendarData)
        """
    }
}
