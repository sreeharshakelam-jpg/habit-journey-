import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var habitVM: HabitViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var editingName = false
    @State private var nameInput = ""
    @State private var journalReminderEnabled = false
    @State private var reminderTime = Date()

    var body: some View {
        NavigationView {
            ZStack {
                Color.hjBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Hero profile card
                        ProfileHeroCard(editingName: $editingName, nameInput: $nameInput)
                            .padding(.top, 8)

                        // Level progress
                        LevelProgressCard()

                        // Stats grid
                        StatsGridCard()

                        // Achievements
                        AchievementsCard()

                        // Accountability partner concept
                        AccountabilityCard()

                        // Notifications settings
                        NotificationSettingsCard(
                            enabled: $journalReminderEnabled,
                            time: $reminderTime
                        )

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { loadSettings() }
            .onChange(of: journalReminderEnabled) { _ in saveReminderSettings() }
            .onChange(of: reminderTime) { _ in saveReminderSettings() }
        }
    }

    private func loadSettings() {
        let profile = gameVM.userProfile
        journalReminderEnabled = profile.journalReminderEnabled
        var comps = DateComponents()
        comps.hour = profile.journalReminderHour
        comps.minute = profile.journalReminderMinute
        reminderTime = Calendar.current.date(from: comps) ?? Date()
        nameInput = profile.name
    }

    private func saveReminderSettings() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        gameVM.updateJournalReminder(
            enabled: journalReminderEnabled,
            hour: comps.hour ?? 21,
            minute: comps.minute ?? 0
        )
        notificationManager.scheduleJournalReminder(
            hour: comps.hour ?? 21,
            minute: comps.minute ?? 0,
            enabled: journalReminderEnabled
        )
    }
}

// MARK: - Hero Card

private struct ProfileHeroCard: View {
    @EnvironmentObject var gameVM: GameViewModel
    @Binding var editingName: Bool
    @Binding var nameInput: String
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 80, height: 80)

                Text(String(gameVM.userProfile.name.prefix(1)).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }

            if editingName {
                HStack {
                    TextField("Your name", text: $nameInput)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.hjText)
                        .multilineTextAlignment(.center)
                        .focused($focused)
                        .onSubmit { saveName() }

                    Button("Done") { saveName() }
                        .foregroundColor(.hjPrimary)
                }
            } else {
                Button {
                    nameInput = gameVM.userProfile.name
                    editingName = true
                    focused = true
                } label: {
                    HStack(spacing: 6) {
                        Text(gameVM.userProfile.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.hjText)
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.hjSubtext)
                    }
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "flame.fill").foregroundColor(.orange)
                Text("\(gameVM.userProfile.currentStreak) day streak")
                    .font(.subheadline)
                    .foregroundColor(.hjSubtext)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .cardStyle()
    }

    private func saveName() {
        if !nameInput.trimmingCharacters(in: .whitespaces).isEmpty {
            gameVM.updateName(nameInput.trimmingCharacters(in: .whitespaces))
        }
        editingName = false
    }
}

// MARK: - Level Progress

private struct LevelProgressCard: View {
    @EnvironmentObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(gameVM.userProfile.level)")
                        .font(.headline)
                        .foregroundColor(.hjText)
                    Text(gameVM.userProfile.levelTitle)
                        .font(.subheadline)
                        .foregroundColor(.hjPrimaryLight)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(gameVM.userProfile.totalPoints) pts")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.hjGold)
                    Text("\(gameVM.userProfile.pointsToNextLevel) to next level")
                        .font(.caption)
                        .foregroundColor(.hjSubtext)
                }
            }

            MiniProgressBar(
                progress: gameVM.userProfile.levelProgress,
                color: .hjPrimary
            )
        }
        .cardStyle()
    }
}

// MARK: - Stats Grid

private struct StatsGridCard: View {
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Statistics")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.hjText)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatTile(label: "Current Streak", value: "\(gameVM.userProfile.currentStreak)", unit: "days", icon: "flame.fill", color: .orange)
                StatTile(label: "Best Streak", value: "\(gameVM.userProfile.longestStreak)", unit: "days", icon: "crown.fill", color: .hjGold)
                StatTile(label: "Total Points", value: "\(gameVM.userProfile.totalPoints)", unit: "pts", icon: "star.fill", color: .hjPrimary)
                StatTile(label: "Achievements", value: "\(gameVM.userProfile.achievements.count)", unit: "earned", icon: "trophy.fill", color: .hjGreen)
                StatTile(label: "Active Habits", value: "\(habitVM.habits.count)", unit: "habits", icon: "checkmark.seal.fill", color: .hjPrimaryLight)
                StatTile(label: "Journey", value: "\(Int(gameVM.characterPosition * 100))%", unit: "complete", icon: "map.fill", color: Color(red: 0.4, green: 0.8, blue: 0.7))
            }
        }
    }
}

private struct StatTile: View {
    let label: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.hjText)

            VStack(alignment: .leading, spacing: 1) {
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.hjSubtext)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.hjSubtext)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.hjSurface)
        .cornerRadius(14)
    }
}

// MARK: - Achievements

private struct AchievementsCard: View {
    @EnvironmentObject var gameVM: GameViewModel

    var unlockedTypes: Set<AchievementType> {
        Set(gameVM.userProfile.achievements.map { $0.type })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Achievements")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.hjText)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                ForEach(AchievementType.allCases, id: \.self) { type in
                    let locked = !unlockedTypes.contains(type)
                    let fakeAchievement = Achievement(type: type)
                    AchievementBadgeView(achievement: fakeAchievement, locked: locked)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Accountability

private struct AccountabilityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Accountability Partners")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.hjText)
                Spacer()
                Text("Coming Soon")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.hjGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.hjGold.opacity(0.15))
                    .cornerRadius(20)
            }

            Text("Share your journey with friends. Invite accountability partners to celebrate your wins and keep each other on track.")
                .font(.subheadline)
                .foregroundColor(.hjSubtext)

            HStack(spacing: -8) {
                ForEach(0..<4) { i in
                    Circle()
                        .fill(
                            [Color.hjPrimary, Color.hjGreen, Color.hjGold, Color(red: 0.93, green: 0.36, blue: 0.36)][i]
                                .opacity(0.6)
                        )
                        .frame(width: 36, height: 36)
                        .overlay(Circle().stroke(Color.hjSurface, lineWidth: 2))
                        .overlay(
                            Text(["👤", "👤", "👤", "+"][i])
                                .font(.system(size: 14))
                        )
                }
            }
            .padding(.top, 4)
        }
        .cardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.hjPrimary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Notifications

private struct NotificationSettingsCard: View {
    @Binding var enabled: Bool
    @Binding var time: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Reminders")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.hjText)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Journal Reminder")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.hjText)
                    Text("Get a nudge to write in your journal")
                        .font(.caption)
                        .foregroundColor(.hjSubtext)
                }
                Spacer()
                Toggle("", isOn: $enabled)
                    .labelsHidden()
                    .tint(.hjPrimary)
            }

            if enabled {
                DatePicker("Reminder time", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .transition(.opacity)
            }
        }
        .cardStyle()
        .animation(.spring(), value: enabled)
    }
}
