import SwiftUI

struct BattleView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedEnemy: Enemy?
    @State private var battleLog: [String] = []
    @State private var showBattleResult = false
    @State private var lastBattleWon = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("⚔️ Enemy Battle")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Defeat bad habits to earn XP and coins")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // Player Stats in Battle
                HStack(spacing: 20) {
                    VStack {
                        Text("⚡ \(appState.player.energy)/\(appState.player.maxEnergy)")
                            .font(.title3)
                            .foregroundColor(.yellow)
                        Text("Energy")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    VStack {
                        Text("⚔️ Lv.\(appState.player.level)")
                            .font(.title3)
                            .foregroundColor(.red)
                        Text("Power")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    VStack {
                        Text("💰 \(appState.player.coins)")
                            .font(.title3)
                            .foregroundColor(.green)
                        Text("Coins")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))

                // Enemy Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(Array(appState.enemies.enumerated()), id: \.element.id) { index, enemy in
                        EnemyCard(enemy: enemy) {
                            startBattle(at: index)
                        }
                    }
                }

                // Battle Log
                if !battleLog.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📜 Battle Log")
                            .font(.headline)
                            .foregroundColor(.white)

                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(battleLog.indices, id: \.self) { i in
                                        Text(battleLog[i])
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(battleLog[i].contains("💥") ? .red : battleLog[i].contains("✅") ? .green : .gray)
                                            .id(i)
                                    }
                                }
                            }
                            .frame(height: 150)
                            .onChange(of: battleLog.count) { _ in
                                withAnimation {
                                    proxy.scrollTo(battleLog.count - 1, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
                }

                // Defeated Enemies
                if !appState.player.enemiesDefeated.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🏆 Defeated Enemies")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(appState.player.enemiesDefeated, id: \.self) { name in
                            HStack {
                                Text("💀")
                                Text(name)
                                    .foregroundColor(.gray)
                                    .strikethrough()
                                Spacer()
                                Text("SLAIN")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
                }
            }
            .padding(30)
        }
    }

    func startBattle(at index: Int) {
        guard appState.player.energy >= 2 else {
            battleLog.append("❌ Not enough energy! Wait for refill.")
            return
        }

        var enemy = appState.enemies[index]

        // Battle sequence
        let playerDamage = 10 + (appState.player.level * 2) + Int.random(in: 0...15)
        enemy.health = max(0, enemy.health - playerDamage)
        battleLog.append("⚔️ You hit \(enemy.name) for \(playerDamage) damage!")

        if enemy.health <= 0 {
            enemy.isDefeated = true
            appState.enemies[index] = enemy

            appState.player.xp += enemy.xpReward
            appState.player.totalXP += enemy.xpReward
            appState.player.coins += enemy.coinReward
            appState.player.energy -= 2
            appState.player.enemiesDefeated.append(enemy.name)

            battleLog.append("✅ \(enemy.name) DEFEATED! +\(enemy.xpReward) XP +\(enemy.coinReward) coins")

            if !appState.player.enemiesDefeated.filter({ $0 == enemy.name }).isEmpty {
                NotificationManager.shared.sendMilestoneNotification("You defeated \(enemy.name)! 🎉")
            }
        } else {
            appState.player.energy -= 2
            let enemyHit = enemy.damage + Int.random(in: -5...5)
            appState.player.energy = max(0, appState.player.energy - max(0, enemyHit / 5))

            battleLog.append("💥 \(enemy.name) hit you back! \(enemy.name) HP: \(enemy.health)/\(enemy.maxHealth)")
            appState.enemies[index] = enemy
        }

        DataManager.shared.savePlayer(appState.player)
        DataManager.shared.saveEnemies(appState.enemies)
    }
}

struct EnemyCard: View {
    let enemy: Enemy
    let onFight: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(enemy.icon)
                .font(.system(size: 40))

            Text(enemy.name)
                .font(.headline)
                .foregroundColor(.white)

            if enemy.isDefeated {
                Text("DEFEATED 💀")
                    .font(.caption)
                    .foregroundColor(.red)
                    .strikethrough()
            } else {
                // Health Bar
                ProgressView(value: Double(enemy.health) / Double(enemy.maxHealth))
                    .tint(.red)
                    .frame(height: 6)

                Text("HP: \(enemy.health)/\(enemy.maxHealth)")
                    .font(.caption2)
                    .foregroundColor(.gray)

                HStack {
                    Text("XP: \(enemy.xpReward)")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text("💰: \(enemy.coinReward)")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }

                Button("⚔️ Fight (-2⚡)") {
                    onFight()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(enemy.isDefeated)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(enemy.isDefeated ? Color.white.opacity(0.01) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(enemy.isDefeated ? Color.gray.opacity(0.2) : Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
