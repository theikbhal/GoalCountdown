import SwiftUI

struct MainDashboard: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            switch selectedTab {
            case 0: CountdownView().environmentObject(appState)
            case 1: AttendanceView().environmentObject(appState)
            case 2: JournalView().environmentObject(appState)
            case 3: BattleView().environmentObject(appState)
            case 4: InventoryView().environmentObject(appState)
            case 5: RevenueView().environmentObject(appState)
            default: CountdownView().environmentObject(appState)
            }
        }
        .navigationTitle("GoalCountdown")
    }

    var sidebar: some View {
        VStack {
            // Player Card
            VStack(spacing: 8) {
                Text("⚔️")
                    .font(.system(size: 40))
                Text(appState.player.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Lv.\(appState.player.level) \(appState.player.levelTitle)")
                    .font(.caption)
                    .foregroundColor(.orange)

                // XP Bar
                ProgressView(value: appState.player.xpProgress)
                    .tint(.green)
                    .frame(height: 6)

                HStack {
                    Label("\(appState.player.streak)🔥", systemImage: "flame")
                        .font(.caption2)
                    Spacer()
                    Label("\(appState.player.coins)💰", systemImage: "bitcoinsign.circle")
                        .font(.caption2)
                }
                .foregroundColor(.gray)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))

            List([
                TabItem(name: "Countdown", icon: "timer"),
                TabItem(name: "Check-In", icon: "checkmark.circle"),
                TabItem(name: "Journal", icon: "book"),
                TabItem(name: "Battle", icon: "bolt.fill"),
                TabItem(name: "Inventory", icon: "backpack"),
                TabItem(name: "Revenue", icon: "dollarsign.circle"),
            ], selection: $selectedTab) { item in
                Label(item.name, systemImage: item.icon)
            }
            .listStyle(.sidebar)

            Spacer()

            // Energy
            VStack(spacing: 4) {
                HStack {
                    Text("⚡ Energy")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Spacer()
                    Text("\(appState.player.energy)/\(appState.player.maxEnergy)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                ProgressView(value: Double(appState.player.energy) / Double(appState.player.maxEnergy))
                    .tint(.yellow)
                    .frame(height: 8)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(minWidth: 200)
    }
}

struct TabItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}
