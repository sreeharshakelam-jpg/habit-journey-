import SwiftUI

struct JournalView: View {
    @EnvironmentObject var journalVM: JournalViewModel
    @EnvironmentObject var gameVM: GameViewModel
    @State private var showEntry = false
    @State private var selectedDate: Date = Date()
    @State private var editingEntry: JournalEntry? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.hjBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Today's prompt or entry
                        TodayJournalCard(showEntry: $showEntry)
                            .padding(.top, 8)

                        // Mood trend
                        if !journalVM.entries.isEmpty {
                            MoodTrendCard()
                        }

                        // Past entries
                        if !journalVM.entries.isEmpty {
                            PastEntriesSection(editingEntry: $editingEntry, showEntry: $showEntry)
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editingEntry = nil
                        showEntry = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18))
                            .foregroundColor(.hjPrimary)
                    }
                }
            }
            .sheet(isPresented: $showEntry) {
                JournalEntryEditorView(existingEntry: editingEntry)
                    .environmentObject(journalVM)
                    .environmentObject(gameVM)
            }
            .onChange(of: showEntry) { isShowing in
                if !isShowing { editingEntry = nil }
            }
        }
    }
}

// MARK: - Today Card

private struct TodayJournalCard: View {
    @EnvironmentObject var journalVM: JournalViewModel
    @Binding var showEntry: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.hjSubtext)
                        .textCase(.uppercase)
                        .tracking(0.8)
                    Text(Date().fullDate)
                        .font(.headline)
                        .foregroundColor(.hjText)
                }
                Spacer()
                if let entry = journalVM.todayEntry {
                    Text(entry.mood.emoji)
                        .font(.system(size: 28))
                }
            }

            if let entry = journalVM.todayEntry {
                // Show existing entry preview
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.content.isEmpty ? "No content written yet." : entry.content)
                        .font(.subheadline)
                        .foregroundColor(entry.content.isEmpty ? .hjSubtext : .hjText)
                        .lineLimit(3)

                    if !entry.gratitude.isEmpty {
                        HStack(spacing: 4) {
                            Text("🙏")
                            Text(entry.gratitude.prefix(2).joined(separator: " · "))
                                .font(.caption)
                                .foregroundColor(.hjSubtext)
                                .lineLimit(1)
                        }
                    }

                    Button {
                        showEntry = true
                    } label: {
                        Label("Edit entry", systemImage: "pencil")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.hjPrimary)
                    }
                }
            } else {
                // Prompt to write
                VStack(spacing: 12) {
                    Text("What's on your mind today?")
                        .font(.subheadline)
                        .foregroundColor(.hjSubtext)
                        .multilineTextAlignment(.center)

                    Button {
                        showEntry = true
                    } label: {
                        Label("Write today's entry", systemImage: "pencil.line")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(LinearGradient.primaryGradient)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Mood Trend

private struct MoodTrendCard: View {
    @EnvironmentObject var journalVM: JournalViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Trend")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.hjText)

            HStack(spacing: 0) {
                ForEach(Array(journalVM.entries.prefix(7).enumerated()), id: \.offset) { idx, entry in
                    VStack(spacing: 6) {
                        Text(entry.mood.emoji)
                            .font(.system(size: 22))
                        Text(entry.date.shortDate)
                            .font(.system(size: 9))
                            .foregroundColor(.hjSubtext)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Past Entries

private struct PastEntriesSection: View {
    @EnvironmentObject var journalVM: JournalViewModel
    @Binding var editingEntry: JournalEntry?
    @Binding var showEntry: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Past Entries")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.hjText)

            ForEach(journalVM.entries.filter { !$0.date.isToday }) { entry in
                JournalEntryRow(entry: entry)
                    .onTapGesture {
                        editingEntry = entry
                        showEntry = true
                    }
            }
        }
    }
}

private struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(entry.mood.emoji)
                    .font(.system(size: 22))
                Rectangle()
                    .fill(Color.hjSurface2)
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 32)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.date.relativeLabel)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.hjText)
                    Spacer()
                    Text(entry.mood.rawValue)
                        .font(.caption)
                        .foregroundColor(.hjSubtext)
                }

                if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(.subheadline)
                        .foregroundColor(.hjSubtext)
                        .lineLimit(2)
                }

                if !entry.intention.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 10))
                            .foregroundColor(.hjPrimary)
                        Text(entry.intention)
                            .font(.caption)
                            .foregroundColor(.hjPrimaryLight)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Journal Entry Editor

struct JournalEntryEditorView: View {
    @EnvironmentObject var journalVM: JournalViewModel
    @EnvironmentObject var gameVM: GameViewModel
    @Environment(\.dismiss) var dismiss

    var existingEntry: JournalEntry?

    @State private var content: String = ""
    @State private var selectedMood: Mood = .okay
    @State private var gratitude: [String] = ["", "", ""]
    @State private var intention: String = ""
    @FocusState private var focusedField: Int?

    var body: some View {
        NavigationView {
            ZStack {
                Color.hjBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Mood picker
                        MoodPickerSection(selected: $selectedMood)

                        // Main content
                        VStack(alignment: .leading, spacing: 8) {
                            Text("How did your day go?")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.hjSubtext)

                            TextEditor(text: $content)
                                .font(.body)
                                .foregroundColor(.hjText)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 120)
                                .padding(12)
                                .background(Color.hjSurface2)
                                .cornerRadius(12)
                        }
                        .cardStyle()

                        // Gratitude
                        VStack(alignment: .leading, spacing: 12) {
                            Text("3 things I'm grateful for 🙏")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.hjSubtext)

                            ForEach(0..<3, id: \.self) { i in
                                HStack(spacing: 10) {
                                    Text("\(i + 1).")
                                        .font(.subheadline)
                                        .foregroundColor(.hjSubtext)
                                        .frame(width: 20)

                                    TextField("I'm grateful for...", text: $gratitude[i])
                                        .font(.body)
                                        .foregroundColor(.hjText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Color.hjSurface2)
                                        .cornerRadius(10)
                                        .focused($focusedField, equals: i)
                                }
                            }
                        }
                        .cardStyle()

                        // Intention
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tomorrow's intention 🎯")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.hjSubtext)

                            TextField("I intend to...", text: $intention)
                                .font(.body)
                                .foregroundColor(.hjText)
                                .padding(12)
                                .background(Color.hjSurface2)
                                .cornerRadius(12)
                        }
                        .cardStyle()

                        Spacer(minLength: 40)
                    }
                    .padding(16)
                }
            }
            .navigationTitle(existingEntry == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.hjSubtext)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .foregroundColor(.hjPrimary)
                }
            }
            .onAppear { prefill() }
        }
    }

    private func prefill() {
        if let e = existingEntry {
            content = e.content
            selectedMood = e.mood
            gratitude = (e.gratitude + ["", "", ""]).prefix(3).map { $0 }
            intention = e.intention
        }
    }

    private func save() {
        let filtered = gratitude.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let date = existingEntry?.date ?? Date()
        let entry = JournalEntry(
            date: date,
            content: content,
            mood: selectedMood,
            gratitude: filtered,
            intention: intention
        )
        journalVM.save(entry)
        gameVM.recalculate()
        dismiss()
    }
}

private struct MoodPickerSection: View {
    @Binding var selected: Mood

    var body: some View {
        VStack(spacing: 10) {
            Text("How are you feeling?")
                .font(.headline)
                .foregroundColor(.hjText)

            HStack(spacing: 0) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        withAnimation(.spring()) { selected = mood }
                    } label: {
                        VStack(spacing: 4) {
                            Text(mood.emoji)
                                .font(.system(size: selected == mood ? 32 : 24))
                                .scaleEffect(selected == mood ? 1.15 : 1.0)
                            Text(mood.rawValue)
                                .font(.system(size: 10, weight: selected == mood ? .semibold : .regular))
                                .foregroundColor(selected == mood ? .hjText : .hjSubtext)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selected == mood ? Color.hjPrimary.opacity(0.15) : Color.clear)
                        .cornerRadius(12)
                    }
                    .animation(.spring(response: 0.3), value: selected)
                }
            }
        }
        .cardStyle()
    }
}
