import SwiftData
import Foundation

@Model
final class ChatMessage {
    var id: UUID = UUID()
    var content: String = ""
    var isUser: Bool = true
    var timestamp: Date = Date()

    init(content: String, isUser: Bool) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}
