import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }

            ChatView()
                .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right") }

            IncomeView()
                .tabItem { Label("Income", systemImage: "eurosign.circle") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(AppColors.accent)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Divider()
        }
    }
}
