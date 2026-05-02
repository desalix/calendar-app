import Foundation
import SwiftData

@Observable
final class ChatViewModel {

    var inputText: String = ""
    var isLoading: Bool = false

    // MARK: - Send message
    // Inserts the user message, calls AIService, then inserts the AI response.

    func send(context: ModelContext) {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }

        inputText = ""
        isLoading = true

        let userMsg = ChatMessage(content: text, isUser: true)
        context.insert(userMsg)

        // Fetch all events so the AI service can reason about the calendar
        let allEvents = (try? context.fetch(FetchDescriptor<Event>())) ?? []

        Task {
            let reply = await AIService.shared.respond(to: text, events: allEvents, context: context)
            await MainActor.run {
                let aiMsg = ChatMessage(content: reply, isUser: false)
                context.insert(aiMsg)
                self.isLoading = false
            }
        }
    }
}
