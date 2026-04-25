import SwiftUI

struct HomeView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @EnvironmentObject var gameVM: GameViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.hjBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        HeaderSection()
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        // Journey Path
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.hjSurface)
                                .padding(.horizontal, 16)

                            JourneyPathView(characterPosition: gameVM.characterPosition)
                                .frame(height: 340)
                                .padding(.horizontal, 16)
                        }
                        .frame(height: 340)
                        .padding(.top, 16)

                        // Stats row
                        StatsRowView()
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        // Today's habits
                        TodaySection()
                            .padding(.horizontal, 16)
                            .padding(.top, 20)

                        // 7-day challenges
                        ChallengeSection()
                            .padding(.horizontal, 16)
                            .padding(.top, 20)

                        // Goal suggestions
                        if !habitVM.goalSuggestions.isEmpty {
                            SuggestionsSection()
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }

                        Spacer(minLength: 32)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Header

private struct HeaderSection: View {
    @EnvironmentObject var gameVM: GameViewModel

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.subheadline)
                    .foregroundColor(.hjSubtext)
                Text(gameVM.userProfile.name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.hjText)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(gameVM.userProfile.currentStreak)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.hjText)
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.hjSubtext)
                }
                Text("Lv. \(gameVM.userProfile.level) · \(gameVM.userProfile.levelTitle)")
                    .font(.caption)
                    .foregroundColor(.hjPrimaryLight)
            }
        }
    }

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning 🌅" }
        if hour < 17 { return "Good afternoon ☀️" }
        return "Good evening 🌙"
    }
}

// MARK: - Stats Row

private struct StatsRowView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        HStack(spacing: 12) {
            StatCard(label: "Points", value: "\(gameVM.userProfile.totalPoints)", icon: "star.fill", color: .hjGold)
            StatCard(label: "Best Streak", value: "\(gameVM.userProfile.longestStreak)d", icon: "crown.fill", color: .hjPrimary)
            StatCard(label: "Active Habits", value: "\(habitVM.habits.count)", icon: "checkmark.seal.fill", color: .hjGreen)
        }
    }
}

private struct StatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.hjText)
            Text(label)
                .font(.caption2)
                .foregroundColor(.hjSubtext)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.hjSurface)
        .cornerRadius(14)
    }
}

// MARK: - Today Section

private struct TodaySection: View {
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.hjText)
                Spacer()
                Text(Date().shortDate)
                    .font(.subheadline)
                    .foregroundColor(.hjSubtext)
            }

            if habitVM.habits.isEmpty {
                EmptyHabitsPrompt()
            } else {
                ForEach(habitVM.habits) { habit in
                    HabitCardView(habit: habit)
                        .environmentObject(habitVM)
                }
            }
        }
    }
}

private struct EmptyHabitsPrompt: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("🌱")
                .font(.system(size: 48))
            Text("Start your journey")
                .font(.headline)
                .foregroundColor(.hjText)
            Text("Add your first habit to begin building your identity, one small step at a time.")
                .font(.subheadline)
                .foregroundColor(.hjSubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.hjSurface)
        .cornerRadius(16)
    }
}

// MARK: - Suggestions Section

private struct SuggestionsSection: View {
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.hjGold)
                Text("Smart Adjustments")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.hjText)
            }

            ForEach(habitVM.goalSuggestions) { suggestion in
                GoalSuggestionCard(suggestion: suggestion)
                    .environmentObject(habitVM)
            }
        }
    }
}

private struct GoalSuggestionCard: View {
    let suggestion: HabitViewModel.GoalSuggestion
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(suggestion.isIncrease ? "📈" : "📉")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.habitName)
                        .font(.headline)
                        .foregroundColor(.hjText)
                    Text(suggestion.isIncrease ? "Level Up?" : "Make it Easier?")
                        .font(.caption)
                        .foregroundColor(.hjSubtext)
                }
            }

            Text(suggestion.reason)
                .font(.subheadline)
                .foregroundColor(.hjSubtext)

            HStack {
                Text("\(suggestion.currentTarget.toHoursMinutes)/wk → \(suggestion.suggestedTarget.toHoursMinutes)/wk")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.hjPrimaryLight)
                Spacer()
                Button("Apply") { habitVM.applySuggestion(suggestion) }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.hjBackground)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.hjPrimary)
                    .cornerRadius(20)

                Button("Skip") { habitVM.dismissSuggestion(suggestion) }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.hjSubtext)
                    .padding(.horizontal, 10)
            }
        }
        .padding(16)
        .background(Color.hjSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.hjGold.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - 7-Day Challenge Section

private struct HabitChallenge: Codable {
    var title: String
    var emoji: String
    var startDate: Date

    var dayNumber: Int {
        let days = Calendar.current.dateComponents([.day],
            from: Calendar.current.startOfDay(for: startDate),
            to: Calendar.current.startOfDay(for: Date())).day ?? 0
        return min(days + 1, 7)
    }

    var isComplete: Bool { dayNumber >= 7 }
}

private struct ChallengeSection: View {
    @State private var active: HabitChallenge? = nil
    @State private var showPicker = false

    private let presets: [(String, String)] = [
        ("No phone first 30 min", "📵"),
        ("Drink 8 glasses of water", "💧"),
        ("Walk 10 minutes outdoors", "🚶"),
        ("Read 10 pages", "📖"),
        ("Write 3 gratitudes", "✍️"),
        ("Sleep by 10 PM", "🌙"),
        ("Meditate 5 minutes", "🧘"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.circle.fill").foregroundColor(.hjGold)
                    Text("7-Day Challenge")
                        .font(.title3).fontWeight(.bold).foregroundColor(.hjText)
                }
                Spacer()
                if active == nil || active!.isComplete {
                    Button(active?.isComplete == true ? "New Challenge" : "Start") {
                        showPicker = true
                    }
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(.hjBackground)
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(LinearGradient.primaryGradient)
                    .cornerRadius(20)
                    .shadow(color: Color.hjPrimary.opacity(0.35), radius: 4)
                }
            }

            if let challenge = active {
                ActiveChallengeCard(challenge: challenge)
            } else {
                EmptyChallengePrompt { showPicker = true }
            }
        }
        .onAppear { loadChallenge() }
        .sheet(isPresented: $showPicker) {
            ChallengePicker(presets: presets) { title, emoji in
                active = HabitChallenge(title: title, emoji: emoji, startDate: Date())
                saveChallenge()
            }
        }
    }

    private func loadChallenge() {
        guard let data = UserDefaults.standard.data(forKey: "hj_challenge_v1"),
              let decoded = try? JSONDecoder().decode(HabitChallenge.self, from: data) else { return }
        active = decoded
    }

    private func saveChallenge() {
        if let c = active, let data = try? JSONEncoder().encode(c) {
            UserDefaults.standard.set(data, forKey: "hj_challenge_v1")
        }
    }
}

private struct ActiveChallengeCard: View {
    let challenge: HabitChallenge

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Text(challenge.emoji).font(.system(size: 32))
                VStack(alignment: .leading, spacing: 3) {
                    Text(challenge.title)
                        .font(.subheadline).fontWeight(.semibold).foregroundColor(.hjText)
                    if challenge.isComplete {
                        Text("Challenge complete! 🎉")
                            .font(.caption).foregroundColor(.hjGreen)
                    } else {
                        Text("Day \(challenge.dayNumber) of 7")
                            .font(.caption).foregroundColor(.hjSubtext)
                    }
                }
                Spacer()
                Text("\(challenge.dayNumber)/7")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(challenge.isComplete ? .hjGreen : .hjPrimary)
            }

            // 7-dot progress
            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    ZStack {
                        Circle()
                            .fill(day <= challenge.dayNumber
                                ? AnyView(LinearGradient.primaryGradient)
                                : AnyView(Color.hjSurface2))
                            .frame(width: 30, height: 30)
                            .shadow(color: day <= challenge.dayNumber ? Color.hjPrimary.opacity(0.4) : .clear, radius: 4)

                        if day <= challenge.dayNumber {
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold)).foregroundColor(.white)
                        } else {
                            Text("\(day)").font(.system(size: 10)).foregroundColor(.hjSubtext)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(Color.hjSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(challenge.isComplete ? Color.hjGreen.opacity(0.4) : Color.hjPrimary.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct EmptyChallengePrompt: View {
    let onStart: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Text("⚡").font(.system(size: 32))
            VStack(alignment: .leading, spacing: 4) {
                Text("Pick a 7-day challenge").font(.subheadline).fontWeight(.semibold).foregroundColor(.hjText)
                Text("Build momentum with a focused one-week goal")
                    .font(.caption).foregroundColor(.hjSubtext)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.hjSurface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.hjPrimary.opacity(0.15), lineWidth: 1))
        .onTapGesture { onStart() }
    }
}

private struct ChallengePicker: View {
    let presets: [(String, String)]
    let onSelect: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.hjBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3).fill(Color.hjSurface2)
                    .frame(width: 40, height: 5).padding(.top, 16).padding(.bottom, 20)

                Text("Choose a Challenge")
                    .font(.title2).fontWeight(.bold).foregroundColor(.hjText)
                    .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(presets, id: \.0) { title, emoji in
                            Button {
                                onSelect(title, emoji)
                                dismiss()
                            } label: {
                                HStack(spacing: 14) {
                                    Text(emoji).font(.system(size: 28))
                                    Text(title)
                                        .font(.subheadline).fontWeight(.medium).foregroundColor(.hjText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption).foregroundColor(.hjSubtext)
                                }
                                .padding(16)
                                .background(Color.hjSurface)
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.hjPrimary.opacity(0.1), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}
