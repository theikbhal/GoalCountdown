import SwiftUI

struct RevenueView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddEntry = false

    private var totalRev: Double {
        appState.revenue.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("💰 Revenue Tracker")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    if let goal = appState.goal {
                        let remaining = max(0, goal.targetAmount - totalRev)
                        Text("₹\(Int(remaining)) remaining to reach ₹\(Int(goal.targetAmount / 100000))L goal")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                HStack(spacing: 16) {
                    RevenueStat(icon: "💵", title: "Total Earned", value: "₹\(Int(totalRev))", color: .green)
                    RevenueStat(icon: "📅", title: "This Month", value: "₹\(Int(monthlyRevenue()))", color: .blue)
                    RevenueStat(icon: "📊", title: "Avg/Day", value: "₹\(Int(avgPerDay()))", color: .orange)
                }

                if let goal = appState.goal {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Progress to Goal")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text(String(format: "%.1f%%", min(100, totalRev / goal.targetAmount * 100)))
                                .font(.headline)
                                .foregroundColor(.green)
                        }

                        ProgressView(value: min(1.0, totalRev / goal.targetAmount))
                            .tint(.green)
                            .frame(height: 12)
                            .clipShape(Capsule())

                        HStack {
                            Text("₹\(Int(totalRev))")
                                .font(.caption)
                                .foregroundColor(.green)
                            Spacer()
                            Text("₹\(Int(goal.targetAmount))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                }

                Button(action: { showAddEntry = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Revenue Entry")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                if appState.revenue.isEmpty {
                    VStack(spacing: 12) {
                        Text("📊")
                            .font(.system(size: 50))
                        Text("No revenue entries yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Track every rupee earned. Every entry is progress.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(40)
                } else {
                    VStack(spacing: 8) {
                        Text("Recent Entries")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(appState.revenue.suffix(10).reversed()) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.source)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(entry.category)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("+₹\(Int(entry.amount))")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    Text(entry.date, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.03)))
                        }
                    }
                }
            }
            .padding(30)
        }
        .sheet(isPresented: $showAddEntry) {
            AddRevenueView(isPresented: $showAddEntry)
                .environmentObject(appState)
        }
    }

    func monthlyRevenue() -> Double {
        let calendar = Calendar.current
        let now = Date()
        return appState.revenue
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    func avgPerDay() -> Double {
        guard !appState.revenue.isEmpty else { return 0 }
        let total = appState.revenue.reduce(0) { $0 + $1.amount }
        let goal = appState.goal
        let daysElapsed = goal?.daysElapsed ?? 1
        return total / Double(max(1, daysElapsed))
    }
}

struct RevenueStat: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 24))
            Text(value)
                .font(.system(.title3, design: .monospaced))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
    }
}

struct AddRevenueView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    @State private var amount = ""
    @State private var source = ""
    @State private var category = "Freelancing"
    @State private var notes = ""

    let categories = ["Freelancing", "Product Sale", "Service", "Consulting", "Content", "App", "Other"]

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Revenue")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Text("₹")
                    .font(.title)
                    .foregroundColor(.green)
                TextField("Amount", text: $amount)
                    .textFieldStyle(.roundedBorder)
            }

            TextField("Source (e.g., Client Project)", text: $source)
                .textFieldStyle(.roundedBorder)

            Picker("Category", selection: $category) {
                ForEach(categories, id: \.self) { cat in
                    Text(cat).tag(cat)
                }
            }
            .pickerStyle(.segmented)

            TextField("Notes (optional)", text: $notes)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Add") {
                    if let amountValue = Double(amount), !source.isEmpty {
                        let entry = RevenueEntry(
                            date: Date(),
                            amount: amountValue,
                            source: source,
                            category: category,
                            notes: notes
                        )
                        appState.revenue.append(entry)
                        DataManager.shared.saveRevenue(appState.revenue)
                        isPresented = false
                    }
                }
                .disabled(amount.isEmpty || source.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 400)
    }
}
