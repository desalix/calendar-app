import SwiftUI

struct ContentView: View {

    @EnvironmentObject var theme: ColorTheme
    @State private var selectedTab = 0

    private let tabs: [(label: String, icon: String)] = [
        ("Calendar", "calendar"),
        ("Chat",     "bubble.left.and.bubble.right"),
        ("Income",   "eurosign.circle"),
        ("Settings", "gearshape"),
    ]

    var body: some View {
        VStack(spacing: 0) {

            // ── Content area — fills all space between top and bottom bar ──
            Group {
                switch selectedTab {
                case 0: CalendarView()
                case 1: ChatView()
                case 2: IncomeView()
                default: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Bottom bar ─────────────────────────────────────────────────
            Divider()

            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { i in
                    Button { selectedTab = i } label: {
                        VStack(spacing: 3) {
                            Image(systemName: tabs[i].icon)
                                .font(.system(size: 22))
                            Text(tabs[i].label)
                                .font(.caption2)
                        }
                        .foregroundColor(selectedTab == i ? theme.accent : Color(UIColor.systemGray))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .accessibilityLabel(tabs[i].label)
                }
            }
            .background(
                Color(UIColor.secondarySystemBackground)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}
