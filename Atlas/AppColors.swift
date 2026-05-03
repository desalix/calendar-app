import SwiftUI

// MARK: - Color Theme (replaces AppColors enum)
// All colors are persisted to UserDefaults so the user can change them
// from Settings → Colors.

class ColorTheme: ObservableObject {

    // MARK: Hard-coded defaults
    private enum Default {
        static let assignment  = "#5B9CF6"
        static let exam        = "#F97316"
        static let basketball  = "#22C55E"
        static let football    = "#8B5CF6"
        static let event       = "#EC4899"
        static let other       = "#64748B"
        static let roperoTag   = "#3B82F6"
        static let postresTag  = "#EF4444"
        static let userBubble  = "#007AFF"
        static let aiBubble    = "#E9E9EB"
        static let accent      = "#007AFF"
        static let background  = "#F2F2F7"
    }

    // MARK: Published hex strings (persisted)
    @Published var assignmentHex:  String { didSet { save("color.assignment",  assignmentHex)  } }
    @Published var examHex:        String { didSet { save("color.exam",        examHex)        } }
    @Published var basketballHex:  String { didSet { save("color.basketball",  basketballHex)  } }
    @Published var footballHex:    String { didSet { save("color.football",    footballHex)    } }
    @Published var eventHex:       String { didSet { save("color.event",       eventHex)       } }
    @Published var otherHex:       String { didSet { save("color.other",       otherHex)       } }
    @Published var roperoTagHex:   String { didSet { save("color.roperoTag",   roperoTagHex)   } }
    @Published var postresTagHex:  String { didSet { save("color.postresTag",  postresTagHex)  } }
    @Published var userBubbleHex:  String { didSet { save("color.userBubble",  userBubbleHex)  } }
    @Published var aiBubbleHex:    String { didSet { save("color.aiBubble",    aiBubbleHex)    } }
    @Published var accentHex:      String { didSet { save("color.accent",      accentHex)      } }
    @Published var backgroundHex:  String { didSet { save("color.background",  backgroundHex)  } }

    // MARK: Computed Color properties
    var assignment:  Color { Color(hex: assignmentHex)  }
    var exam:        Color { Color(hex: examHex)        }
    var basketball:  Color { Color(hex: basketballHex)  }
    var football:    Color { Color(hex: footballHex)    }
    var event:       Color { Color(hex: eventHex)       }
    var other:       Color { Color(hex: otherHex)       }
    var roperoTag:   Color { Color(hex: roperoTagHex)   }
    var postresTag:  Color { Color(hex: postresTagHex)  }
    var userBubble:  Color { Color(hex: userBubbleHex)  }
    var aiBubble:    Color { Color(hex: aiBubbleHex)    }
    var accent:      Color { Color(hex: accentHex)      }
    var background:  Color { Color(hex: backgroundHex)  }
    var card:        Color { .white }

    init() {
        let ud = UserDefaults.standard
        assignmentHex  = ud.string(forKey: "color.assignment")  ?? Default.assignment
        examHex        = ud.string(forKey: "color.exam")        ?? Default.exam
        basketballHex  = ud.string(forKey: "color.basketball")  ?? Default.basketball
        footballHex    = ud.string(forKey: "color.football")    ?? Default.football
        eventHex       = ud.string(forKey: "color.event")       ?? Default.event
        otherHex       = ud.string(forKey: "color.other")       ?? Default.other
        roperoTagHex   = ud.string(forKey: "color.roperoTag")   ?? Default.roperoTag
        postresTagHex  = ud.string(forKey: "color.postresTag")  ?? Default.postresTag
        userBubbleHex  = ud.string(forKey: "color.userBubble")  ?? Default.userBubble
        aiBubbleHex    = ud.string(forKey: "color.aiBubble")    ?? Default.aiBubble
        accentHex      = ud.string(forKey: "color.accent")      ?? Default.accent
        backgroundHex  = ud.string(forKey: "color.background")  ?? Default.background
    }

    func color(for token: AppColor) -> Color {
        switch token {
        case .assignment: return assignment
        case .exam:       return exam
        case .basketball: return basketball
        case .football:   return football
        case .event:      return event
        case .other:      return other
        }
    }

    func resetToDefaults() {
        assignmentHex  = Default.assignment
        examHex        = Default.exam
        basketballHex  = Default.basketball
        footballHex    = Default.football
        eventHex       = Default.event
        otherHex       = Default.other
        roperoTagHex   = Default.roperoTag
        postresTagHex  = Default.postresTag
        userBubbleHex  = Default.userBubble
        aiBubbleHex    = Default.aiBubble
        accentHex      = Default.accent
        backgroundHex  = Default.background
    }

    private func save(_ key: String, _ value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

// MARK: - Color ↔ Hex helpers
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255,
                  blue: Double(b) / 255, opacity: Double(a) / 255)
    }

    var hexString: String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
