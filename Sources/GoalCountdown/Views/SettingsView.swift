import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var reminderEnabled = true
    @State private var launchAtLogin = true

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Daily Morning Reminder (8 AM)", isOn: $reminderEnabled)
                    .onChange(of: reminderEnabled) { val in
                        if val {
                            NotificationManager.shared.scheduleDailyReminder()
                        }
                    }
            }

            Section("Startup") {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { val in
                        if val {
                            LaunchAgentManager.shared.installLaunchAgent()
                        } else {
                            LaunchAgentManager.shared.uninstallLaunchAgent()
                        }
                    }
            }

            Section("Danger Zone") {
                Button("Reset All Data", role: .destructive) {
                    DataManager.shared.resetAll()
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 300)
        .navigationTitle("Settings")
    }
}
