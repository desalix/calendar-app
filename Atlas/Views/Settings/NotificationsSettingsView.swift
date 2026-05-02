import SwiftUI
import SwiftData

struct NotificationsSettingsView: View {

    @Query private var configs: [NotificationConfig]

    var body: some View {
        List {
            ForEach(NotificationEventType.allCases, id: \.self) { eventType in
                Section {
                    let typeConfigs = configs
                        .filter { $0.eventType == eventType }
                        .sorted { $0.reminderIndex < $1.reminderIndex }

                    ForEach(typeConfigs) { config in
                        NotificationRowView(config: config)
                    }
                } header: {
                    Text(eventType.rawValue)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Row

struct NotificationRowView: View {

    @Bindable var config: NotificationConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Reminder \(config.reminderIndex + 1)")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Toggle("", isOn: $config.isEnabled)
                    .labelsHidden()
                    .tint(AppColors.accent)
            }

            if config.isEnabled {
                Picker("", selection: $config.timing) {
                    ForEach(NotificationTiming.allCases, id: \.self) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColors.accent)
                .padding(.leading, -8)
            }
        }
        .padding(.vertical, 4)
    }
}
