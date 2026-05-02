import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: SubjectsSettingsView()) {
                    settingsRow(
                        icon: "book.closed.fill",
                        color: Color.orange,
                        label: "Subjects"
                    )
                }

                NavigationLink(destination: NotificationsSettingsView()) {
                    settingsRow(
                        icon: "bell.fill",
                        color: Color.red,
                        label: "Notifications"
                    )
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func settingsRow(icon: String, color: Color, label: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(color)
                .cornerRadius(7)
            Text(label)
                .font(.body)
        }
        .padding(.vertical, 2)
    }
}
