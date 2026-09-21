import Foundation
import SwiftUI

class DataManager {
    static let shared = DataManager()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // Keys
    private enum Keys {
        static let goal = "com.goalcountdown.goal"
        static let attendance = "com.goalcountdown.attendance"
        static let journal = "com.goalcountdown.journal"
        static let playerProfile = "com.goalcountdown.player"
        static let enemies = "com.goalcountdown.enemies"
        static let assets = "com.goalcountdown.assets"
        static let achievements = "com.goalcountdown.achievements"
        static let revenue = "com.goalcountdown.revenue"
        static let onboardingComplete = "com.goalcountdown.onboarding"
        static let dailyReminder = "com.goalcountdown.reminder"
    }

    // MARK: - Goal
    func saveGoal(_ goal: Goal) {
        if let data = try? encoder.encode(goal) {
            defaults.set(data, forKey: Keys.goal)
        }
    }

    func loadGoal() -> Goal? {
        guard let data = defaults.data(forKey: Keys.goal),
              let goal = try? decoder.decode(Goal.self, from: data) else {
            return nil
        }
        return goal
    }

    // MARK: - Attendance
    func saveAttendance(_ records: [Attendance]) {
        if let data = try? encoder.encode(records) {
            defaults.set(data, forKey: Keys.attendance)
        }
    }

    func loadAttendance() -> [Attendance] {
        guard let data = defaults.data(forKey: Keys.attendance),
              let records = try? decoder.decode([Attendance].self, from: data) else {
            return []
        }
        return records
    }

    func todayAttendance() -> Attendance? {
        let calendar = Calendar.current
        return loadAttendance().first {
            calendar.isDate($0.date, inSameDayAs: Date())
        }
    }

    // MARK: - Journal
    func saveJournal(_ entries: [JournalEntry]) {
        if let data = try? encoder.encode(entries) {
            defaults.set(data, forKey: Keys.journal)
        }
    }

    func loadJournal() -> [JournalEntry] {
        guard let data = defaults.data(forKey: Keys.journal),
              let entries = try? decoder.decode([JournalEntry].self, from: data) else {
            return []
        }
        return entries
    }

    // MARK: - Player Profile
    func savePlayer(_ player: PlayerProfile) {
        if let data = try? encoder.encode(player) {
            defaults.set(data, forKey: Keys.playerProfile)
        }
    }

    func loadPlayer() -> PlayerProfile {
        guard let data = defaults.data(forKey: Keys.playerProfile),
              let player = try? decoder.decode(PlayerProfile.self, from: data) else {
            return .empty
        }
        return player
    }

    // MARK: - Enemies
    func saveEnemies(_ enemies: [Enemy]) {
        if let data = try? encoder.encode(enemies) {
            defaults.set(data, forKey: Keys.enemies)
        }
    }

    func loadEnemies() -> [Enemy] {
        guard let data = defaults.data(forKey: Keys.enemies),
              let enemies = try? decoder.decode([Enemy].self, from: data) else {
            return Enemy.allEnemies
        }
        return enemies
    }

    // MARK: - Assets
    func saveAssets(_ assets: [DigitalAsset]) {
        if let data = try? encoder.encode(assets) {
            defaults.set(data, forKey: Keys.assets)
        }
    }

    func loadAssets() -> [DigitalAsset] {
        guard let data = defaults.data(forKey: Keys.assets),
              let assets = try? decoder.decode([DigitalAsset].self, from: data) else {
            return []
        }
        return assets
    }

    // MARK: - Revenue
    func saveRevenue(_ entries: [RevenueEntry]) {
        if let data = try? encoder.encode(entries) {
            defaults.set(data, forKey: Keys.revenue)
        }
    }

    func loadRevenue() -> [RevenueEntry] {
        guard let data = defaults.data(forKey: Keys.revenue),
              let entries = try? decoder.decode([RevenueEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func totalRevenue() -> Double {
        loadRevenue().reduce(0) { $0 + $1.amount }
    }

    // MARK: - Onboarding
    func isOnboardingComplete() -> Bool {
        defaults.bool(forKey: Keys.onboardingComplete)
    }

    func completeOnboarding() {
        defaults.set(true, forKey: Keys.onboardingComplete)
    }

    // MARK: - Reset
    func resetAll() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
    }
}
