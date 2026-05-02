import SwiftData
import Foundation

@Model
final class Subject {
    var id: UUID = UUID()
    var name: String = ""
    var isDefault: Bool = false
    var createdAt: Date = Date()

    init(name: String, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}
