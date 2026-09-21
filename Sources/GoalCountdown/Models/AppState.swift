import Foundation
import SwiftUI

// MARK: - Main Goal Model
struct Goal: Codable, Identifiable {
    var id = UUID()
    var title: String
    var targetAmount: Double
    var currency: String
    var startDate: Date
    var endDate: Date
    var iconName: String
    var createdAt: Date

    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return max(0, components.day ?? 0)
    }

    var daysElapsed: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: Date())
        return max(0, components.day ?? 0)
    }

    var totalDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return max(1, components.day ?? 730)
    }

    var progress: Double {
        Double(daysElapsed) / Double(totalDays)
    }

    var percentageComplete: Double {
        min(1.0, progress * 100)
    }
}

// MARK: - Daily Attendance
struct Attendance: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var checkedIn: Bool
    var mood: Mood
    var energyLevel: Int // 1-10
    var notes: String

    enum Mood: String, Codable, CaseIterable {
        case fire = "🔥"
        case strong = "💪"
        case okay = "😐"
        case tired = "😴"
        case struggle = "😫"

        var label: String {
            switch self {
            case .fire: return "On Fire"
            case .strong: return "Strong"
            case .okay: return "Okay"
            case .tired: return "Tired"
            case .struggle: return "Struggling"
            }
        }
    }
}

// MARK: - Journal Entry
struct JournalEntry: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var title: String
    var content: String
    var category: Category
    var tags: [String]
    var mood: Attendance.Mood

    enum Category: String, Codable, CaseIterable {
        case win = "🏆 Win"
        case learning = "📚 Learning"
        case setback = "💔 Setback"
        case plan = "📋 Plan"
        case reflection = "🪞 Reflection"
        case revenue = "💰 Revenue"
    }
}

// MARK: - Gamification
struct PlayerProfile: Codable {
    var name: String
    var level: Int
    var xp: Int
    var totalXP: Int
    var energy: Int
    var maxEnergy: Int
    var streak: Int
    var longestStreak: Int
    var coins: Int
    var titles: [String]
    var currentTitle: String
    var achievements: [Achievement]
    var enemiesDefeated: [String]
    var assets: [DigitalAsset]
    var lastEnergyRefill: Date

    static let empty = PlayerProfile(
        name: "Warrior",
        level: 1,
        xp: 0,
        totalXP: 0,
        energy: 10,
        maxEnergy: 10,
        streak: 0,
        longestStreak: 0,
        coins: 100,
        titles: ["Newcomer"],
        currentTitle: "Newcomer",
        achievements: [],
        enemiesDefeated: [],
        assets: [],
        lastEnergyRefill: Date()
    )

    var xpForNextLevel: Int {
        level * 100 + (level * level * 10)
    }

    var xpProgress: Double {
        Double(xp) / Double(xpForNextLevel)
    }

    var levelTitle: String {
        switch level {
        case 1...5: return "Rookie"
        case 6...10: return "Fighter"
        case 11...20: return "Warrior"
        case 21...30: return "Champion"
        case 31...50: return "Legend"
        case 51...75: return "Mythic"
        case 76...100: return "Divine"
        default: return "Ascended"
        }
    }
}

// MARK: - Achievement
struct Achievement: Codable, Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var icon: String
    var unlockedAt: Date?
    var rarity: Rarity

    enum Rarity: String, Codable {
        case common, rare, epic, legendary, mythic

        var color: String {
            switch self {
            case .common: return "gray"
            case .rare: return "blue"
            case .epic: return "purple"
            case .legendary: return "orange"
            case .mythic: return "red"
            }
        }
    }
}

// MARK: - Enemy (Bad Habits / Obstacles)
struct Enemy: Codable, Identifiable {
    var id = UUID()
    var name: String
    var health: Int
    var maxHealth: Int
    var damage: Int
    var xpReward: Int
    var coinReward: Int
    var icon: String
    var isDefeated: Bool

    static let allEnemies: [Enemy] = [
        Enemy(name: "Procrastination", health: 100, maxHealth: 100, damage: 15, xpReward: 50, coinReward: 25, icon: "🦥", isDefeated: false),
        Enemy(name: "Doubt", health: 80, maxHealth: 80, damage: 10, xpReward: 40, coinReward: 20, icon: "🫠", isDefeated: false),
        Enemy(name: "Fear", health: 120, maxHealth: 120, damage: 20, xpReward: 60, coinReward: 30, icon: "👻", isDefeated: false),
        Enemy(name: "Complacency", health: 90, maxHealth: 90, damage: 12, xpReward: 45, coinReward: 22, icon: "😴", isDefeated: false),
        Enemy(name: "Distraction", health: 70, maxHealth: 70, damage: 8, xpReward: 35, coinReward: 18, icon: "📱", isDefeated: false),
        Enemy(name: "Overthinking", health: 110, maxHealth: 110, damage: 18, xpReward: 55, coinReward: 28, icon: "🌀", isDefeated: false),
        Enemy(name: "Isolation", health: 85, maxHealth: 85, damage: 14, xpReward: 42, coinReward: 21, icon: "🏝️", isDefeated: false),
        Enemy(name: "Burnout", health: 130, maxHealth: 130, damage: 22, xpReward: 70, coinReward: 35, icon: "🔥", isDefeated: false),
    ]
}

// MARK: - Digital Asset
struct DigitalAsset: Codable, Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var icon: String
    var type: AssetType
    var acquiredAt: Date?

    enum AssetType: String, Codable {
        case skill, tool, shield, weapon, companion, badge
    }
}

// MARK: - Onboarding Step
struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let content: String
    let color: Color
}

// MARK: - Revenue Entry
struct RevenueEntry: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var amount: Double
    var source: String
    var category: String
    var notes: String
}
