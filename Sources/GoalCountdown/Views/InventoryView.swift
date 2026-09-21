import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("📦 Inventory")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Tab Selector
                Picker("", selection: $selectedTab) {
                    Text("👤 Profile").tag(0)
                    Text("🏆 Achievements").tag(1)
                    Text("🎯 Titles").tag(2)
                    Text("🛡️ Assets").tag(3)
                }
                .pickerStyle(.segmented)

                switch selectedTab {
                case 0: profileView
                case 1: achievementsView
                case 2: titlesView
                case 3: assetsView
                default: profileView
                }
            }
            .padding(30)
        }
    }

    var profileView: some View {
        VStack(spacing: 20) {
            // Avatar
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    Text("⚔️")
                        .font(.system(size: 50))
                }

                Text(appState.player.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("\(appState.player.currentTitle)")
                    .font(.headline)
                    .foregroundColor(.orange)
            }

            // Stats Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ProfileStat(icon: "⭐", title: "Level", value: "\(appState.player.level)")
                ProfileStat(icon: "📊", title: "Total XP", value: "\(appState.player.totalXP)")
                ProfileStat(icon: "🔥", title: "Current Streak", value: "\(appState.player.streak) days")
                ProfileStat(icon: "🏆", title: "Best Streak", value: "\(appState.player.longestStreak) days")
                ProfileStat(icon: "💰", title: "Coins", value: "\(appState.player.coins)")
                ProfileStat(icon: "🗡️", title: "Enemies Defeated", value: "\(appState.player.enemiesDefeated.count)")
            }

            // XP Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Level \(appState.player.level)")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Level \(appState.player.level + 1)")
                        .foregroundColor(.gray)
                }
                .font(.caption)

                ProgressView(value: appState.player.xpProgress)
                    .tint(.purple)
                    .frame(height: 8)

                Text("\(appState.player.xp)/\(appState.player.xpForNextLevel) XP to next level")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
        }
    }

    var achievementsView: some View {
        VStack(spacing: 16) {
            if appState.player.achievements.isEmpty {
                VStack(spacing: 12) {
                    Text("🏆")
                        .font(.system(size: 50))
                    Text("No achievements yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Keep showing up daily to unlock achievements!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(40)
            } else {
                ForEach(appState.player.achievements) { achievement in
                    HStack(spacing: 12) {
                        Text(achievement.icon)
                            .font(.system(size: 30))
                        VStack(alignment: .leading) {
                            Text(achievement.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(achievement.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(achievement.rarity.rawValue.uppercased())
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(rarityColor(achievement.rarity).opacity(0.2))
                            .foregroundColor(rarityColor(achievement.rarity))
                            .cornerRadius(4)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
                }
            }
        }
    }

    var titlesView: some View {
        VStack(spacing: 12) {
            ForEach(appState.player.titles, id: \.self) { title in
                HStack {
                    Text(title == appState.player.currentTitle ? "✅" : "🔒")
                        .font(.title3)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(title == appState.player.currentTitle ? .orange : .gray)
                    Spacer()
                    if title == appState.player.currentTitle {
                        Text("ACTIVE")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(title == appState.player.currentTitle ? Color.orange.opacity(0.1) : Color.white.opacity(0.03))
                )
            }

            // Available titles
            VStack(alignment: .leading, spacing: 8) {
                Text("🔒 Locked Titles")
                    .font(.headline)
                    .foregroundColor(.gray)

                let allTitles = ["Rookie", "Fighter", "Warrior", "Champion", "Legend", "Mythic", "Divine", "Ascended"]
                ForEach(allTitles.filter { !appState.player.titles.contains($0) }, id: \.self) { title in
                    HStack {
                        Text("🔒")
                        Text(title)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(levelForTitle(title))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
        }
    }

    var assetsView: some View {
        VStack(spacing: 12) {
            if appState.playerAssets.isEmpty {
                VStack(spacing: 12) {
                    Text("🛡️")
                        .font(.system(size: 50))
                    Text("No assets yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Defeat enemies and complete milestones to earn assets!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(40)
            } else {
                ForEach(appState.playerAssets) { asset in
                    HStack(spacing: 12) {
                        Text(asset.icon)
                            .font(.system(size: 30))
                        VStack(alignment: .leading) {
                            Text(asset.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(asset.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(asset.type.rawValue.uppercased())
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
                }
            }
        }
    }

    func rarityColor(_ rarity: Achievement.Rarity) -> Color {
        switch rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        case .mythic: return .red
        }
    }

    func levelForTitle(_ title: String) -> String {
        switch title {
        case "Rookie": return "Lv. 1"
        case "Fighter": return "Lv. 6"
        case "Warrior": return "Lv. 11"
        case "Champion": return "Lv. 21"
        case "Legend": return "Lv. 31"
        case "Mythic": return "Lv. 51"
        case "Divine": return "Lv. 76"
        case "Ascended": return "Lv. 100"
        default: return ""
        }
    }
}

struct ProfileStat: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 20))
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.05)))
    }
}
