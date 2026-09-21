import Foundation

class GamificationManager {
    static let shared = GamificationManager()

    func checkIn(player: inout PlayerProfile) -> (xpGained: Int, leveledUp: Bool, newLevel: Int?) {
        let streakBonus = min(player.streak, 30)
        let xpGained = 10 + streakBonus
        let coinsGained = 5 + (streakBonus / 2)

        player.xp += xpGained
        player.totalXP += xpGained
        player.coins += coinsGained
        player.streak += 1

        if player.streak > player.longestStreak {
            player.longestStreak = player.streak
        }

        var leveledUp = false
        var newLevel: Int?

        while player.xp >= player.xpForNextLevel {
            player.xp -= player.xpForNextLevel
            player.level += 1
            player.maxEnergy += 2
            player.energy = player.maxEnergy
            leveledUp = true
            newLevel = player.level

            // Unlock titles at milestones
            let newTitle = player.levelTitle
            if !player.titles.contains(newTitle) {
                player.titles.append(newTitle)
                player.currentTitle = newTitle
            }
        }

        // Check achievements
        checkAchievements(player: &player)

        return (xpGained, leveledUp, newLevel)
    }

    func useEnergy(player: inout PlayerProfile, amount: Int) -> Bool {
        guard player.energy >= amount else { return false }
        player.energy -= amount
        return true
    }

    func refillEnergyIfNeeded(player: inout PlayerProfile) {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDate(player.lastEnergyRefill, inSameDayAs: now) == false {
            let hoursSinceLastRefill = calendar.dateComponents([.hour], from: player.lastEnergyRefill, to: now).hour ?? 0

            if hoursSinceLastRefill >= 4 {
                let refillAmount = min(player.maxEnergy, hoursSinceLastRefill / 4)
                player.energy = min(player.maxEnergy, player.energy + refillAmount)
                player.lastEnergyRefill = now
            }
        }
    }

    func fightEnemy(player: inout PlayerProfile, enemy: inout Enemy) -> (won: Bool, damageDealt: Int) {
        guard player.energy >= 2 else { return (false, 0) }

        player.energy -= 2

        let damage = 10 + (player.level * 2) + Int.random(in: 0...10)
        enemy.health = max(0, enemy.health - damage)

        if enemy.health <= 0 {
            enemy.isDefeated = true
            player.xp += enemy.xpReward
            player.totalXP += enemy.xpReward
            player.coins += enemy.coinReward
            player.enemiesDefeated.append(enemy.name)
            return (true, damage)
        }

        return (false, damage)
    }

    func buyAsset(player: inout PlayerProfile, asset: DigitalAsset, cost: Int) -> Bool {
        guard player.coins >= cost else { return false }
        player.coins -= cost
        return true
    }

    private func checkAchievements(player: inout PlayerProfile) {
        let p = player
        let checks: [(String, String, String, Achievement.Rarity, Bool)] = [
            ("First Blood", "Complete your first check-in", "⚔️", .common, p.totalXP > 0),
            ("Week Warrior", "7-day streak", "🔥", .rare, p.streak >= 7),
            ("Unstoppable", "30-day streak", "💎", .epic, p.streak >= 30),
            ("Iron Will", "90-day streak", "🏆", .legendary, p.streak >= 90),
            ("Level 10", "Reach level 10", "⭐", .rare, p.level >= 10),
            ("Level 25", "Reach level 25", "🌟", .epic, p.level >= 25),
            ("Level 50", "Reach level 50", "💫", .legendary, p.level >= 50),
            ("100 Day Club", "100-day streak", "👑", .mythic, p.streak >= 100),
            ("Coin Collector", "Earn 1000 coins", "🪙", .rare, p.coins >= 1000),
            ("Enemy Slayer", "Defeat 5 enemies", "🗡️", .epic, p.enemiesDefeated.count >= 5),
        ]

        for (name, desc, icon, rarity, condition) in checks {
            if !player.achievements.contains(where: { $0.name == name }) && condition {
                let achievement = Achievement(
                    name: name,
                    description: desc,
                    icon: icon,
                    unlockedAt: Date(),
                    rarity: rarity
                )
                player.achievements.append(achievement)
            }
        }
    }
}
