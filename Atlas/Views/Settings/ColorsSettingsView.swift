import SwiftUI

struct ColorsSettingsView: View {

    @EnvironmentObject var theme: ColorTheme
    @State private var showingResetAlert = false

    var body: some View {
        List {
            Section("Global") {
                colorRow("Accent", $theme.accentHex,
                         note: "Buttons, toggles, selected tab")
                colorRow("Background", $theme.backgroundHex,
                         note: "App background surface")
            }

            Section("Calendar Events") {
                colorRow("Assignment", $theme.assignmentHex,
                         note: "School assignment pills")
                colorRow("Exam", $theme.examHex,
                         note: "School exam pills")
                colorRow("Basketball", $theme.basketballHex,
                         note: "Basketball work entries")
                colorRow("Football", $theme.footballHex,
                         note: "Football work entries")
                colorRow("Paid Event", $theme.eventHex,
                         note: "Paid event work entries")
                colorRow("Other", $theme.otherHex,
                         note: "Other category events")
            }

            Section("Basketball Tags") {
                colorRow("Ropero dot", $theme.roperoTagHex,
                         note: "Ropero tag indicator dot")
                colorRow("Postres dot", $theme.postresTagHex,
                         note: "Postres tag indicator dot")
            }

            Section("Chat Bubbles") {
                colorRow("Your messages", $theme.userBubbleHex,
                         note: "Outgoing chat bubble background")
                colorRow("AI messages", $theme.aiBubbleHex,
                         note: "Incoming chat bubble background")
            }

            Section {
                Button(role: .destructive) {
                    showingResetAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Reset to Defaults")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Colors")
        .navigationBarTitleDisplayMode(.large)
        .alert("Reset Colors?", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) { theme.resetToDefaults() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All colors will be restored to their defaults.")
        }
    }

    private func colorRow(_ name: String, _ hex: Binding<String>, note: String) -> some View {
        ColorPicker(selection: Binding(
            get: { Color(hex: hex.wrappedValue) },
            set: { hex.wrappedValue = $0.hexString }
        ), supportsOpacity: false) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
