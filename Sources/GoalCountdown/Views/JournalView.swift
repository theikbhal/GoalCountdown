import SwiftUI

struct JournalView: View {
    @EnvironmentObject var appState: AppState
    @State private var showNewEntry = false
    @State private var editingEntry: JournalEntry?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Journal")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("What did you do today to achieve your goal?")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: { showNewEntry = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Entry")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                // Stats
                HStack(spacing: 16) {
                    JournalStat(icon: "📖", title: "Total Entries", value: "\(appState.journal.count)")
                    JournalStat(icon: "🏆", title: "Wins", value: "\(appState.journal.filter { $0.category == .win }.count)")
                    JournalStat(icon: "📚", title: "Learnings", value: "\(appState.journal.filter { $0.category == .learning }.count)")
                    JournalStat(icon: "📅", title: "This Week", value: "\(entriesThisWeek())")
                }

                // Entries
                if appState.journal.isEmpty {
                    VStack(spacing: 16) {
                        Text("📝")
                            .font(.system(size: 50))
                        Text("No journal entries yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Start documenting your journey. Every entry is proof you're moving forward.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
                } else {
                    ForEach(appState.journal.reversed()) { entry in
                        JournalEntryCard(entry: entry) {
                            editingEntry = entry
                        } onDelete: {
                            appState.journal.removeAll { $0.id == entry.id }
                            DataManager.shared.saveJournal(appState.journal)
                        }
                    }
                }
            }
            .padding(30)
        }
        .sheet(isPresented: $showNewEntry) {
            NewJournalEntryView(isPresented: $showNewEntry)
                .environmentObject(appState)
        }
        .sheet(item: $editingEntry) { entry in
            EditJournalEntryView(entry: entry, isPresented: .init(
                get: { editingEntry != nil },
                set: { if !$0 { editingEntry = nil } }
            ))
            .environmentObject(appState)
        }
    }

    func entriesThisWeek() -> Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return appState.journal.filter { $0.date > weekAgo }.count
    }
}

struct JournalStat: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 20))
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.category.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.blue)
                Spacer()
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(entry.mood.rawValue)
                Menu {
                    Button("Edit", action: onEdit)
                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.gray)
                }
                .menuStyle(.borderlessButton)
            }

            Text(entry.title)
                .font(.headline)
                .foregroundColor(.white)

            Text(entry.content)
                .font(.body)
                .foregroundColor(.gray)
                .lineLimit(4)

            if !entry.tags.isEmpty {
                HStack {
                    ForEach(entry.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
    }
}

struct NewJournalEntryView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var content = ""
    @State private var category: JournalEntry.Category = .win
    @State private var mood: Attendance.Mood = .strong
    @State private var tags = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("New Journal Entry")
                .font(.title2)
                .fontWeight(.bold)

            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)

            Picker("Category", selection: $category) {
                ForEach(JournalEntry.Category.allCases, id: \.self) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
            .pickerStyle(.segmented)

            Picker("Mood", selection: $mood) {
                ForEach(Attendance.Mood.allCases, id: \.self) { m in
                    Text("\(m.rawValue) \(m.label)").tag(m)
                }
            }

            TextEditor(text: $content)
                .frame(minHeight: 150)
                .border(Color.gray.opacity(0.3))

            TextField("Tags (comma separated)", text: $tags)

            HStack {
                Button("Cancel") { isPresented = false }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Save") {
                    let entry = JournalEntry(
                        date: Date(),
                        title: title,
                        content: content,
                        category: category,
                        tags: tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                        mood: mood
                    )
                    appState.journal.append(entry)
                    DataManager.shared.saveJournal(appState.journal)
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.isEmpty || content.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 500)
    }
}

struct EditJournalEntryView: View {
    let entry: JournalEntry
    @Binding var isPresented: Bool
    @EnvironmentObject var appState: AppState
    @State private var title: String
    @State private var content: String
    @State private var category: JournalEntry.Category
    @State private var mood: Attendance.Mood
    @State private var tags: String

    init(entry: JournalEntry, isPresented: Binding<Bool>) {
        self.entry = entry
        self._isPresented = isPresented
        _title = State(initialValue: entry.title)
        _content = State(initialValue: entry.content)
        _category = State(initialValue: entry.category)
        _mood = State(initialValue: entry.mood)
        _tags = State(initialValue: entry.tags.joined(separator: ", "))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Journal Entry")
                .font(.title2)
                .fontWeight(.bold)

            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)

            Picker("Category", selection: $category) {
                ForEach(JournalEntry.Category.allCases, id: \.self) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
            .pickerStyle(.segmented)

            TextEditor(text: $content)
                .frame(minHeight: 150)
                .border(Color.gray.opacity(0.3))

            TextField("Tags (comma separated)", text: $tags)

            HStack {
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Save") {
                    if let idx = appState.journal.firstIndex(where: { $0.id == entry.id }) {
                        appState.journal[idx].title = title
                        appState.journal[idx].content = content
                        appState.journal[idx].category = category
                        appState.journal[idx].mood = mood
                        appState.journal[idx].tags = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        DataManager.shared.saveJournal(appState.journal)
                    }
                    isPresented = false
                }
                .disabled(title.isEmpty || content.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 500)
    }
}
