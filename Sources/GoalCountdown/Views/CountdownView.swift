import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentDate = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                if let goal = appState.goal {
                    // Main Countdown
                    VStack(spacing: 16) {
                        Text(goal.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("⏱️")
                            .font(.system(size: 60))

                        HStack(spacing: 20) {
                            CountdownUnit(value: goal.daysRemaining, label: "DAYS", color: .red)
                            CountdownUnit(value: hoursRemaining(goal), label: "HOURS", color: .orange)
                            CountdownUnit(value: minutesRemaining(goal), label: "MINS", color: .yellow)
                            CountdownUnit(value: secondsCurrent(), label: "SECS", color: .green)
                        }
                        .padding(.vertical, 20)

                        // Progress Bar
                        VStack(spacing: 8) {
                            ProgressView(value: goal.progress)
                                .tint(
                                    LinearGradient(
                                        colors: [.red, .orange, .yellow, .green],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 12)
                                .clipShape(Capsule())

                            HStack {
                                Text("Day \(goal.daysElapsed) of \(goal.totalDays)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.1f%% complete", goal.percentageComplete))
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                    )

                    // Stats Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        StatCard(icon: "📅", title: "Days Left", value: "\(goal.daysRemaining)", color: .red)
                        StatCard(icon: "🔥", title: "Streak", value: "\(appState.player.streak) days", color: .orange)
                        StatCard(icon: "⭐", title: "Level", value: "\(appState.player.level)", color: .yellow)
                        StatCard(icon: "🏆", title: "Achievements", value: "\(appState.player.achievements.count)", color: .purple)
                        StatCard(icon: "🗡️", title: "Enemies Slain", value: "\(appState.player.enemiesDefeated.count)", color: .red)
                        StatCard(icon: "💰", title: "Revenue", value: "₹\(Int(appState.revenue.reduce(0) { $0 + $1.amount }))", color: .green)
                    }

                    // Motivational Quote
                    VStack(spacing: 12) {
                        Text("\"\(randomQuote())\"")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(.white.opacity(0.8))
                            .italic()
                            .multilineTextAlignment(.center)

                        Text("— \(randomAuthor())")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
                } else {
                    Text("No goal set")
                        .foregroundColor(.gray)
                }
            }
            .padding(30)
        }
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }

    func hoursRemaining(_ goal: Goal) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: Date(), to: goal.endDate)
        return max(0, (components.hour ?? 0) % 24)
    }

    func minutesRemaining(_ goal: Goal) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: Date(), to: goal.endDate)
        return max(0, (components.minute ?? 0) % 60)
    }

    func secondsCurrent() -> Int {
        Calendar.current.component(.second, from: currentDate)
    }

    func randomQuote() -> String {
        let quotes = [
            "The only way to do great work is to love what you do.",
            "It's not about how hard you hit. It's about how hard you can get hit and keep moving forward.",
            "Success is not final, failure is not fatal: it is the courage to continue that counts.",
            "Your time is limited, don't waste it living someone else's life.",
            "The future belongs to those who believe in the beauty of their dreams.",
            "In the middle of difficulty lies opportunity.",
            "Bismillah. Trust the process.",
            "跌倒了七次，站起来八次。Fall seven times, stand up eight.",
            "Wa man yatawakkal 'alallah, fa-huwa hasbuh.",
            "Discipline is the bridge between goals and accomplishment."
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return quotes[day % quotes.count]
    }

    func randomAuthor() -> String {
        let authors = ["Steve Jobs", "Rocky Balboa", "Winston Churchill", "Steve Jobs", "Eleanor Roosevelt", "Albert Einstein", "Prophet Muhammad ﷺ", "Japanese Proverb", "Quran 65:3", "Jim Rohn"]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return authors[day % authors.count]
    }
}

struct CountdownUnit: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(minWidth: 80)

            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 28))
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
