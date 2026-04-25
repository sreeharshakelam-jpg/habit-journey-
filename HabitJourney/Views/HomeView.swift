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
