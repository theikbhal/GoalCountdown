import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var goal: Goal?
    @Published var attendance: [Attendance] = []
    @Published var journal: [JournalEntry] = []
    @Published var player: PlayerProfile = .empty
    @Published var enemies: [Enemy] = Enemy.allEnemies
    @Published var playerAssets: [DigitalAsset] = []
    @Published var revenue: [RevenueEntry] = []
    @Published var todayAttendance: Attendance?

    func loadData() {
        goal = DataManager.shared.loadGoal()
        attendance = DataManager.shared.loadAttendance()
        journal = DataManager.shared.loadJournal()
        player = DataManager.shared.loadPlayer()
        enemies = DataManager.shared.loadEnemies()
        playerAssets = DataManager.shared.loadAssets()
        revenue = DataManager.shared.loadRevenue()
        todayAttendance = DataManager.shared.todayAttendance()

        GamificationManager.shared.refillEnergyIfNeeded(player: &player)
    }

    func saveAll() {
        if let goal = goal { DataManager.shared.saveGoal(goal) }
        DataManager.shared.saveAttendance(attendance)
        DataManager.shared.saveJournal(journal)
        DataManager.shared.savePlayer(player)
        DataManager.shared.saveEnemies(enemies)
        DataManager.shared.saveAssets(playerAssets)
        DataManager.shared.saveRevenue(revenue)
    }
}
