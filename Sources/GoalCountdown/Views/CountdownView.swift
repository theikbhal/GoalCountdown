import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentDate = Date()
    @State private var showDua = false
    @State private var duaTimer = 0
    @State private var duaCompleted = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let goal = appState.goal {
                    // Main Countdown - Years, Months, Days
                    VStack(spacing: 16) {
                        Text(goal.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("⏱️")
                            .font(.system(size: 50))

                        let remaining = goal.timeRemaining

                        HStack(spacing: 16) {
                            CountdownBigUnit(value: remaining.years, label: "YEARS", color: .red)
                            Text(":")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.gray)
                            CountdownBigUnit(value: remaining.months, label: "MONTHS", color: .orange)
                            Text(":")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.gray)
                            CountdownBigUnit(value: remaining.days, label: "DAYS", color: .yellow)
                        }
                        .padding(.vertical, 16)

                        // Secondary - hours, mins, secs
                        HStack(spacing: 20) {
                            SmallCountdownUnit(value: hoursRemaining(goal), label: "HRS", color: .cyan)
                            SmallCountdownUnit(value: minutesRemaining(goal), label: "MIN", color: .blue)
                            SmallCountdownUnit(value: secondsCurrent(), label: "SEC", color: .green)
                        }

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

                    // Days/Months/Years Passed vs Left
                    HStack(spacing: 16) {
                        let elapsed = goal.timeElapsed
                        let remaining = goal.timeRemaining

                        VStack(spacing: 8) {
                            Text("✅ TIME PASSED")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.green)
                            HStack(spacing: 8) {
                                TimeBreakdown(value: elapsed.years, label: "Y", color: .green)
                                TimeBreakdown(value: elapsed.months, label: "M", color: .green)
                                TimeBreakdown(value: elapsed.days, label: "D", color: .green)
                            }
                            Text("\(goal.daysElapsed) total days fought")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.2), lineWidth: 1))

                        VStack(spacing: 8) {
                            Text("⏳ TIME LEFT")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.red)
                            HStack(spacing: 8) {
                                TimeBreakdown(value: remaining.years, label: "Y", color: .red)
                                TimeBreakdown(value: remaining.months, label: "M", color: .red)
                                TimeBreakdown(value: remaining.days, label: "D", color: .red)
                            }
                            Text("\(goal.daysRemaining) days to go")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.2), lineWidth: 1))
                    }

                    // Dua Section
                    duaSection

                    // Stats Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        StatCard(icon: "📅", title: "Days Left", value: "\(goal.daysRemaining)", color: .red)
                        StatCard(icon: "🔥", title: "Streak", value: "\(appState.player.streak) days", color: .orange)
                        StatCard(icon: "⭐", title: "Level", value: "\(appState.player.level)", color: .yellow)
                        StatCard(icon: "🏆", title: "Achievements", value: "\(appState.player.achievements.count)", color: .purple)
                        StatCard(icon: "🗡️", title: "Enemies Slain", value: "\(appState.player.enemiesDefeated.count)", color: .red)
                        StatCard(icon: "💰", title: "Revenue", value: "₹\(Int(appState.revenue.reduce(0) { $0 + $1.amount }))", color: .green)
                    }

                    // Islamic Values Row
                    valuesRow

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

    // MARK: - Dua Section
    var duaSection: some View {
        VStack(spacing: 16) {
            if showDua {
                VStack(spacing: 16) {
                    Text("🤲")
                        .font(.system(size: 40))

                    Text("One Second Dua")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ")
                        .font(.system(size: 24, design: .serif))
                        .foregroundColor(.yellow)

                    Text("In the name of Allah, the Most Gracious, the Most Merciful")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Divider().background(Color.white.opacity(0.1))

                    VStack(alignment: .leading, spacing: 12) {
                        duaLine("Allah, give me strength to achieve my goal")
                        duaLine("Make halal roji for myself, my wife, my kids, my parents")
                        duaLine("Earn halal, spend halal way")
                        duaLine("Give me patience (Sabr)")
                        duaLine("Give me hikmat (wisdom)")
                        duaLine("Give me aqlaq (good character)")
                        duaLine("Guide me to plan, save, and not waste")
                        duaLine("Make me resourceful and smart")
                        duaLine("Bless my hardwork")
                        duaLine("Keep my self respect and dignity")
                        duaLine("Help me continue namaz and zikir")
                        duaLine("Protect me from shaytan and nafs")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))

                    Text("آمين يَا رَبَّ الْعَالَمِينَ")
                        .font(.system(size: 20, design: .serif))
                        .foregroundColor(.yellow)
                    Text("Ameen Ya Rabbal Alameen")
                        .font(.caption)
                        .foregroundColor(.gray)

                    if !duaCompleted {
                        Button(action: {
                            withAnimation { duaCompleted = true }
                            NotificationManager.shared.sendMilestoneNotification("Dua completed! Allah is with the patient. 🤲")
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Dua Complete - Ameen")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    } else {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Ameen! Dua recorded for today ✓")
                        }
                        .foregroundColor(.green)
                        .font(.headline)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
            }

            Button(action: {
                withAnimation { showDua.toggle() }
            }) {
                HStack {
                    Text(showDua ? "🤲 Hide Dua" : "🤲 One Second Dua")
                        .font(.system(size: 14, weight: .bold))
                    Image(systemName: showDua ? "chevron.up" : "chevron.down")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.yellow.opacity(0.1))
                .foregroundColor(.yellow)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }

    func duaLine(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.yellow)
            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
    }

    // MARK: - Values Row
    var valuesRow: some View {
        let values = [
            ("💰", "Halal Earning"),
            ("🤲", "Sabr"),
            ("📖", "Hikmat"),
            ("✨", "Aqlaq"),
            ("📋", "Plan"),
            ("🏦", "Save"),
            ("🧠", "Smart"),
            ("💪", "Hardwork"),
            ("👑", "Dignity"),
            ("🕌", "Namaz"),
            ("📿", "Zikir"),
        ]

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(values, id: \.1) { icon, label in
                    VStack(spacing: 4) {
                        Text(icon)
                            .font(.system(size: 20))
                        Text(label)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 60)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.03)))
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.02)))
    }

    // MARK: - Helpers
    func hoursRemaining(_ goal: Goal) -> Int {
        let components = Calendar.current.dateComponents([.hour], from: Date(), to: goal.endDate)
        return max(0, (components.hour ?? 0) % 24)
    }

    func minutesRemaining(_ goal: Goal) -> Int {
        let components = Calendar.current.dateComponents([.minute], from: Date(), to: goal.endDate)
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
            "Discipline is the bridge between goals and accomplishment.",
            "Sabr is the key to relief. - Prophet Muhammad ﷺ",
            "Verily, with hardship comes ease. - Quran 94:6",
            "And whoever puts their trust in Allah, He is sufficient for them. - Quran 65:3",
            "Do not lose hope, nor be sad. - Quran 3:139",
            "The strong person is not the one who can wrestle, but the one who controls themselves in anger.",
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return quotes[day % quotes.count]
    }

    func randomAuthor() -> String {
        let authors = [
            "Steve Jobs", "Rocky Balboa", "Winston Churchill", "Steve Jobs",
            "Eleanor Roosevelt", "Albert Einstein", "Prophet Muhammad ﷺ",
            "Japanese Proverb", "Quran 65:3", "Jim Rohn",
            "Prophet Muhammad ﷺ", "Quran 94:6", "Quran 65:3",
            "Quran 3:199", "Prophet Muhammad ﷺ"
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return authors[day % authors.count]
    }
}

// MARK: - Sub-views

struct CountdownBigUnit: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct SmallCountdownUnit: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct TimeBreakdown: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color.opacity(0.6))
        }
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
