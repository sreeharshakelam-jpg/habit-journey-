import SwiftUI

struct MentorView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var habitVM: HabitViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var quoteIndex = 0
    @State private var contract = ""
    @State private var editingName = false
    @State private var nameInput = ""
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()

    private let quotes: [MentorQuote] = [
        MentorQuote("You do not rise to the level of your goals. You fall to the level of your systems.", "James Clear"),
        MentorQuote("Every action you take is a vote for the type of person you wish to become.", "James Clear"),
        MentorQuote("The most practical way to change who you are is to change what you do.", "James Clear"),
        MentorQuote("Success is the product of daily habits — not once-in-a-lifetime transformations.", "James Clear"),
        MentorQuote("Make it obvious, make it attractive, make it easy, make it satisfying.", "James Clear"),
        MentorQuote("A small step forward every day adds up to massive change over time.", "FORGE"),
        MentorQuote("Discipline is choosing what you want most over what you want right now.", "FORGE"),
        MentorQuote("Show up even when you don't feel like it. Consistency beats intensity.", "FORGE"),
        MentorQuote("The quality of your habits determines the quality of your life.", "FORGE"),
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.hjBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        // Profile hero
                        MentorProfileCard(
                            editingName: $editingName,
                            nameInput: $nameInput
                        )
                        .padding(.top, 8)

                        // Quote card
                        QuoteCard(quote: quotes[quoteIndex % quotes.count]) {
                            withAnimation(.easeInOut(duration: 0.25)) { quoteIndex += 1 }
                        }

                        // Identity
                        IdentityCard()

                        // Habit contract
                        HabitContractCard(contract: $contract)

                        // Daily wisdom
                        DailyWisdomSection()

                        // Notification settings
                        MentorNotificationCard(enabled: $reminderEnabled, time: $reminderTime)

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Mentor")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { loadSettings() }
            .onChange(of: reminderEnabled) { _ in saveReminderSettings() }
            .onChange(of: reminderTime)    { _ in saveReminderSettings() }
        }
    }

    private func loadSettings() {
        let p = gameVM.userProfile
        reminderEnabled = p.journalReminderEnabled
        var comps = DateComponents()
        comps.hour = p.journalReminderHour
        comps.minute = p.journalReminderMinute
        reminderTime = Calendar.current.date(from: comps) ?? Date()
        nameInput = p.name
    }

    private func saveReminderSettings() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        gameVM.updateJournalReminder(
            enabled: reminderEnabled,
            hour: comps.hour ?? 21,
            minute: comps.minute ?? 0
        )
        notificationManager.scheduleJournalReminder(
            hour: comps.hour ?? 21,
            minute: comps.minute ?? 0,
            enabled: reminderEnabled
        )
    }
}

// MARK: - Quote Model

private struct MentorQuote {
    let text: String
    let author: String
    init(_ text: String, _ author: String) { self.text = text; self.author = author }
}

// MARK: - Profile Card

private struct MentorProfileCard: View {
    @EnvironmentObject var gameVM: GameViewModel
    @Binding var editingName: Bool
    @Binding var nameInput: String
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.hjPrimary.opacity(0.5), radius: 12)
                Text(String(gameVM.userProfile.name.prefix(1)).uppercased())
                    .font(.system(size: 32, weight: .bold)).foregroundColor(.white)
            }

            if editingName {
                HStack {
                    TextField("Your name", text: $nameInput)
                        .font(.title3).fontWeight(.bold).foregroundColor(.hjText)
                        .multilineTextAlignment(.center)
                        .focused($focused)
                        .onSubmit { saveName() }
                    Button("Done") { saveName() }
                        .fontWeight(.semibold).foregroundColor(.hjPrimary)
                }
            } else {
                Button {
                    nameInput = gameVM.userProfile.name
                    editingName = true
                    focused = true
                } label: {
                    HStack(spacing: 6) {
                        Text(gameVM.userProfile.name)
                            .font(.title3).fontWeight(.bold).foregroundColor(.hjText)
                        Image(systemName: "pencil").font(.caption).foregroundColor(.hjSubtext)
                    }
                }
            }

            HStack(spacing: 20) {
                ProfileStatBadge(icon: "flame.fill",  value: "\(gameVM.userProfile.currentStreak)d",       color: .orange,  label: "Streak")
                ProfileStatBadge(icon: "star.fill",   value: "\(gameVM.userProfile.totalPoints)",           color: .hjGold,  label: "Points")
                ProfileStatBadge(icon: "crown.fill",  value: "Lv. \(gameVM.userProfile.level)",             color: .hjPrimary, label: gameVM.userProfile.levelTitle)
            }

            // Level bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.hjSurface2).frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient.primaryGradient)
                            .frame(width: geo.size.width * gameVM.userProfile.levelProgress, height: 6)
                    }
                }
                .frame(height: 6)
                Text("\(gameVM.userProfile.pointsToNextLevel) pts to Level \(gameVM.userProfile.level + 1)")
                    .font(.caption2).foregroundColor(.hjSubtext)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.hjSurface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.hjPrimary.opacity(0.15), lineWidth: 1))
    }

    private func saveName() {
        let t = nameInput.trimmingCharacters(in: .whitespaces)
        if !t.isEmpty { gameVM.updateName(t) }
        editingName = false
    }
}

private struct ProfileStatBadge: View {
    let icon: String
    let value: String
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
            Text(value).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.hjText)
            Text(label).font(.caption2).foregroundColor(.hjSubtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}

// MARK: - Quote Card

private struct QuoteCard: View {
    let quote: MentorQuote
    let onNext: () -> Void

    var body: some View {
        Button(action: onNext) {
            VStack(spacing: 16) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 26)).foregroundColor(.hjPrimary.opacity(0.55))

                Text(quote.text)
                    .font(.title3).fontWeight(.medium).foregroundColor(.hjText)
                    .multilineTextAlignment(.center).lineSpacing(5)

                HStack {
                    Rectangle().fill(LinearGradient.primaryGradient).frame(height: 1.5)
                    Text("— \(quote.author)")
                        .font(.caption).fontWeight(.semibold).foregroundColor(.hjPrimaryLight).fixedSize()
                    Rectangle().fill(LinearGradient.primaryGradient).frame(height: 1.5)
                }

                Text("Tap for next quote")
                    .font(.caption2).foregroundColor(.hjSubtext)
            }
            .padding(22)
            .background(
                ZStack {
                    Color.hjSurface
                    LinearGradient(
                        colors: [Color.hjPrimary.opacity(0.07), Color.clear],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.hjPrimary.opacity(0.2), lineWidth: 1))
            .shadow(color: Color.hjPrimary.opacity(0.1), radius: 12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Identity Card

private struct IdentityCard: View {
    @EnvironmentObject var gameVM: GameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill.checkmark").font(.system(size: 17)).foregroundColor(.hjPrimary)
                Text("Your Identity")
                    .font(.title3).fontWeight(.bold).foregroundColor(.hjText)
            }

            Text("Based on your streaks and progress, you are becoming:")
                .font(.caption).foregroundColor(.hjSubtext)

            VStack(spacing: 8) {
                IdentityBadge(emoji: "🔥", label: "Consistent",     desc: "\(gameVM.userProfile.currentStreak) days in a row")
                IdentityBadge(emoji: "⭐", label: gameVM.userProfile.levelTitle, desc: "Level \(gameVM.userProfile.level) achiever")
                IdentityBadge(emoji: "📈", label: "Growth-Minded",   desc: "Improving 1% every day")
            }
        }
        .padding(16)
        .background(Color.hjSurface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.hjPrimary.opacity(0.15), lineWidth: 1))
    }
}

private struct IdentityBadge: View {
    let emoji: String
    let label: String
    let desc: String

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji).font(.system(size: 22))
                .frame(width: 40, height: 40).background(Color.hjSurface2).cornerRadius(10)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.subheadline).fontWeight(.semibold).foregroundColor(.hjText)
                Text(desc).font(.caption).foregroundColor(.hjSubtext)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill").foregroundColor(.hjGreen).font(.system(size: 16))
        }
        .padding(12)
        .background(Color.hjBackground)
        .cornerRadius(12)
    }
}

// MARK: - Habit Contract

private struct HabitContractCard: View {
    @Binding var contract: String
    @AppStorage("hj_contract_text") private var savedContract = ""
    @State private var isEditing = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "doc.text.fill").foregroundColor(.hjGold)
                Text("My Habit Contract")
                    .font(.title3).fontWeight(.bold).foregroundColor(.hjText)
                Spacer()
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing { savedContract = contract }
                    else { contract = savedContract }
                    isEditing.toggle()
                    focused = isEditing
                }
                .font(.subheadline).fontWeight(.semibold).foregroundColor(.hjPrimary)
            }

            Text("Write a personal commitment to your habits — review it daily.")
                .font(.caption).foregroundColor(.hjSubtext)

            if isEditing {
                TextEditor(text: $contract)
                    .focused($focused)
                    .font(.subheadline).foregroundColor(.hjText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(Color.hjBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hjPrimary.opacity(0.4), lineWidth: 1))
            } else {
                let display = savedContract.isEmpty
                    ? "I commit to building habits that make me 1% better every day..."
                    : savedContract
                Text(display)
                    .font(.subheadline)
                    .foregroundColor(savedContract.isEmpty ? .hjSubtext : .hjText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.hjBackground)
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.hjSurface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.hjGold.opacity(0.2), lineWidth: 1))
        .onAppear { contract = savedContract }
    }
}

// MARK: - Daily Wisdom

private struct DailyWisdomSection: View {
    private let tips: [(icon: String, color: Color, title: String, body: String)] = [
        ("sun.max.fill",              .hjGold,                          "Morning Ritual",   "Start your day with your most important habit before distractions arise."),
        ("arrow.triangle.2.circlepath", .hjPrimary,                    "Never Miss Twice", "Missing once is an accident. Missing twice starts a new (bad) habit."),
        ("tortoise.fill",             .hjGreen,                         "The 2-Minute Rule","When starting, scale the habit down to just 2 minutes. Show up consistently."),
        ("moon.stars.fill",           Color(red: 0.5, green: 0.3, blue: 0.9), "Evening Review",  "Take 5 minutes each night to reflect on your habits and plan tomorrow."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Wisdom")
                .font(.title3).fontWeight(.bold).foregroundColor(.hjText)

            ForEach(tips, id: \.title) { tip in
                HStack(spacing: 14) {
                    Image(systemName: tip.icon)
                        .font(.system(size: 18)).foregroundColor(tip.color)
                        .frame(width: 42, height: 42)
                        .background(tip.color.opacity(0.12))
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(tip.title).font(.subheadline).fontWeight(.semibold).foregroundColor(.hjText)
                        Text(tip.body).font(.caption).foregroundColor(.hjSubtext)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(14)
                .background(Color.hjSurface)
                .cornerRadius(14)
            }
        }
    }
}

// MARK: - Notification Card

private struct MentorNotificationCard: View {
    @Binding var enabled: Bool
    @Binding var time: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "bell.fill").foregroundColor(.hjPrimary)
                Text("Reminders")
                    .font(.title3).fontWeight(.bold).foregroundColor(.hjText)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Journal Reminder")
                        .font(.subheadline).fontWeight(.medium).foregroundColor(.hjText)
                    Text("Get a nudge to reflect on your day")
                        .font(.caption).foregroundColor(.hjSubtext)
                }
                Spacer()
                Toggle("", isOn: $enabled).labelsHidden().tint(.hjPrimary)
            }

            if enabled {
                DatePicker("Reminder time", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact).labelsHidden().colorScheme(.dark)
                    .transition(.opacity)
            }
        }
        .padding(16)
        .background(Color.hjSurface)
        .cornerRadius(16)
        .animation(.spring(), value: enabled)
    }
}
