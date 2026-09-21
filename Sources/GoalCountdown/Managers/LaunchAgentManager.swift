import Foundation

class LaunchAgentManager {
    static let shared = LaunchAgentManager()

    private var launchAgentPath: String {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent("Library/LaunchAgents/com.goalcountdown.plist").path
    }

    private var appPath: String {
        "/Applications/GoalCountdown.app"
    }

    func installLaunchAgent() {
        let plist: [String: Any] = [
            "Label": "com.goalcountdown",
            "ProgramArguments": [appPath],
            "RunAtLoad": true,
            "KeepAlive": false,
            "StandardOutPath": "/tmp/goalcountdown.log",
            "StandardErrorPath": "/tmp/goalcountdown.err"
        ]

        do {
            let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
            try data.write(to: URL(fileURLWithPath: launchAgentPath))
            print("LaunchAgent installed at \(launchAgentPath)")
        } catch {
            print("Failed to install LaunchAgent: \(error)")
        }
    }

    func uninstallLaunchAgent() {
        try? FileManager.default.removeItem(atPath: launchAgentPath)
    }

    func isInstalled() -> Bool {
        FileManager.default.fileExists(atPath: launchAgentPath)
    }
}
