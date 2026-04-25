import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    @EnvironmentObject var habitVM: HabitViewModel
    @State private var showLog = false

    private var status: CompletionStatus { habitVM.completionStatus(for: habit) }
    private var weeklyPct: Double { habitVM.weeklyCompletionPercentage(for: habit) / 100 }
    private var weeklyMins: Int { habitVM.weeklyCompletedMinutes(for: habit) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(habit.category.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(habit.emoji)
                        .font(.system(size: 20))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.hjText)
                    Text(habit.category.rawValue)
                        .font(.caption)
                        .foregroundColor(habit.category.color)
                }

                Spacer()

                StatusBadge(status: status)
            }

            // Weekly progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("This week")
                        .font(.caption)
                        .foregroundColor(.hjSubtext)
                    Spacer()
                    Text("\(weeklyMins.toHoursMinutes) / \(habit.targetMinutesPerWeek.toHoursMinutes)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.hjText)
                }
                MiniProgressBar(progress: weeklyPct, color: habit.category.color)
            }

            // Log button
            Button {
                showLog = true
            } label: {
                HStack {
                    Image(systemName: status == .none ? "plus.circle.fill" : "pencil.circle.fill")
                    Text(status == .none ? "Log today's progress" : "Update today's log")
                        .fontWeight(.medium)
                }
                .font(.subheadline)
                .foregroundColor(habit.category.color)
            }
        }
        .cardStyle()
        .sheet(isPresented: $showLog) {
            LogTimeView(habit: habit)
                .environmentObject(habitVM)
        }
    }
}

struct StatusBadge: View {
    let status: CompletionStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
            if status != .none {
                Text(status.label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .foregroundColor(status.color)
        .padding(.horizontal, status == .none ? 8 : 10)
        .padding(.vertical, 5)
        .background(status.color.opacity(0.15))
        .cornerRadius(20)
    }
}
