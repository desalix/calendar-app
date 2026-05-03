import Foundation
import SwiftData

@Observable
final class ChatViewModel {

    var inputText: String = ""
    var isLoading: Bool   = false

    func send(context: ModelContext) {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }

        inputText = ""
        isLoading = true

        // Insert the user message first so it's included in the history snapshot
        let userMsg = ChatMessage(content: text, isUser: true)
        context.insert(userMsg)

        let descriptor = FetchDescriptor<ChatMessage>(sortBy: [SortDescriptor(\.timestamp)])
        let history    = (try? context.fetch(descriptor)) ?? []
        let allEvents  = (try? context.fetch(FetchDescriptor<Event>())) ?? []

        Task {
            let reply = await AIService.shared.respond(
                history:  history,
                events:   allEvents,
                context:  context
            )
            await MainActor.run {
                context.insert(ChatMessage(content: reply, isUser: false))
                self.isLoading = false
            }
        }
    }
}
