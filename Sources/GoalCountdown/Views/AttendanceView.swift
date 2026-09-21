import SwiftUI

struct AttendanceView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedMood: Attendance.Mood = .okay
    @State private var energyLevel: Double = 5
    @State private var notes = ""
    @State private var showCheckedIn = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Daily Check-In")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(formattedDate())
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                }

                if showCheckedIn || appState.todayAttendance != nil {
                    alreadyCheckedInView
                } else {
                    checkInForm
                }

                // Streak Calendar
                streakCalendar

                // Recent History
                recentHistory
            }
            .padding(30)
        }
    }

    var checkInForm: some View {
        VStack(spacing: 24) {
            // Mood Selection
            VStack(spacing: 12) {
                Text("How are you feeling?")
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 16) {
                    ForEach(Attendance.Mood.allCases, id: \.self) { mood in
                        Button(action: { withAnimation { selectedMood = mood } }) {
                            VStack(spacing: 4) {
                                Text(mood.rawValue)
                                    .font(.system(size: 32))
                                Text(mood.label)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedMood == mood ? Color.blue.opacity(0.3) : Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedMood == mood ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Energy Level
            VStack(spacing: 8) {
                HStack {
                    Text("⚡ Energy Level")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(energyLevel))/10")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.yellow)
                }

                Slider(value: $energyLevel, in: 1...10, step: 1)
                    .tint(.yellow)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))

            // Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick notes (optional)")
                    .font(.headline)
                    .foregroundColor(.white)

                TextEditor(text: $notes)
                    .frame(height: 80)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                    .foregroundColor(.white)
            }

            // Check In Button
            Button(action: checkIn) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("CHECK IN TODAY")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
    }

    var alreadyCheckedInView: some View {
        VStack(spacing: 16) {
            Text("✅")
                .font(.system(size: 50))
            Text("You showed up today!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)

            if let attendance = appState.todayAttendance {
                HStack(spacing: 20) {
                    VStack {
                        Text(attendance.mood.rawValue)
                            .font(.system(size: 30))
                        Text(attendance.mood.label)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    VStack {
                        Text("⚡ \(attendance.energyLevel)")
                            .font(.title2)
                            .foregroundColor(.yellow)
                        Text("Energy")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    VStack {
                        Text("🔥 \(appState.player.streak)")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("Day Streak")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.1)))
            }

            Text("Come back tomorrow to keep your streak alive!")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(30)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
    }

    var streakCalendar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📅 Last 30 Days")
                .font(.headline)
                .foregroundColor(.white)

            let attendance = appState.attendance
            let calendar = Calendar.current

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                ForEach(0..<30, id: \.self) { dayOffset in
                    let date = calendar.date(byAdding: .day, value: -(29 - dayOffset), to: Date())!
                    let isChecked = attendance.contains { calendar.isDate($0.date, inSameDayAs: date) }

                    RoundedRectangle(cornerRadius: 4)
                        .fill(isChecked ? Color.green.opacity(0.7) : Color.white.opacity(0.1))
                        .frame(height: 20)
                        .overlay(
                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.6))
                        )
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
    }

    var recentHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Check-ins")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(appState.attendance.suffix(7).reversed()) { record in
                HStack {
                    Text(record.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(record.mood.rawValue)
                    Text("⚡\(record.energyLevel)")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
    }

    func checkIn() {
        let attendance = Attendance(
            date: Date(),
            checkedIn: true,
            mood: selectedMood,
            energyLevel: Int(energyLevel),
            notes: notes
        )

        appState.attendance.append(attendance)
        DataManager.shared.saveAttendance(appState.attendance)

        let result = GamificationManager.shared.checkIn(player: &appState.player)
        DataManager.shared.savePlayer(appState.player)

        withAnimation {
            showCheckedIn = true
        }

        if result.leveledUp {
            NotificationManager.shared.sendMilestoneNotification("You reached Level \(result.newLevel ?? appState.player.level)! 🎉")
        }

        if appState.player.streak % 7 == 0 && appState.player.streak > 0 {
            NotificationManager.shared.sendStreakNotification(streak: appState.player.streak)
        }
    }

    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date())
    }
}
