import SwiftUI

// MARK: ─────────────────────────────────────────────────────────────────────
// APP COLOR PALETTE
// Edit the hex strings below to retheme the entire app.
// ─────────────────────────────────────────────────────────────────────────

enum AppColors {

    // MARK: Event type backgrounds (calendar pills & income rows)
    static let assignment  = Color(hex: "#5B9CF6")  // Blue
    static let exam        = Color(hex: "#F97316")  // Orange
    static let basketball  = Color(hex: "#22C55E")  // Green
    static let football    = Color(hex: "#8B5CF6")  // Purple
    static let event       = Color(hex: "#EC4899")  // Pink
    static let other       = Color(hex: "#64748B")  // Slate

    // MARK: Basketball tag dots
    static let roperoTag   = Color(hex: "#3B82F6")  // Blue
    static let postresTag  = Color(hex: "#EF4444")  // Red

    // MARK: Chat bubbles
    static let userBubble  = Color(hex: "#007AFF")  // Apple Blue
    static let aiBubble    = Color(hex: "#E9E9EB")  // System Gray 5

    // MARK: Global accent (buttons, toggles, tint)
    static let accent      = Color(hex: "#007AFF")

    // MARK: Surfaces
    static let background  = Color(hex: "#F2F2F7")
    static let card        = Color.white

    // MARK: Helper — resolve AppColor token → SwiftUI Color
    static func color(for token: AppColor) -> Color {
        switch token {
        case .assignment: return assignment
        case .exam:       return exam
        case .basketball: return basketball
        case .football:   return football
        case .event:      return event
        case .other:      return other
        }
    }
}

// MARK: - Hex initialiser
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
