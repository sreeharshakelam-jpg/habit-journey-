import SwiftUI

struct LogTimeView: View {
    let habit: Habit
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.dismiss) var dismiss

    @State private var minutes: Int
    @State private var notes: String = ""
    @State private var showConfetti = false

    private var existingEntry: HabitEntry? { habitVM.todayEntry(for: habit) }
    private var completionPct: Double {
        guard habit.dailyTargetMinutes > 0 else { return 0 }
        return min(Double(minutes) / Double(habit.dailyTargetMinutes), 1.0)
    }
    private var status: CompletionStatus {
        let pct = completionPct * 100
        if pct >= 80 { return .completed }
        if pct >= 50 { return .partial }
        if pct > 0 { return .missed }
        return .none
    }

    init(habit: Habit) {
        self.habit = habit
        _minutes = State(initialValue: 0)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.hjBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Habit header
                        HabitHeaderCard()

                        // Time input
                        TimeInputSection(minutes: $minutes, dailyTarget: habit.dailyTargetMinutes)

                        // Completion preview
                        if minutes > 0 {
                            CompletionPreviewCard(
                                status: status,
                                percentage: completionPct * 100,
                                minutes: minutes,
                                targetMinutes: habit.dailyTargetMinutes
                            )
                            .transition(.scale.combined(with: .opacity))
                        }

                        // Notes
                        NotesField(notes: $notes)

                        // Motivation quote
                        if minutes == 0 {
                            MotivationCard()
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(16)
                }

                // Confetti effect
                if showConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
            .animation(.spring(), value: minutes)
            .navigationTitle("Log Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.hjSubtext)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .foregroundColor(minutes > 0 ? .hjPrimary : .hjSubtext)
                        .disabled(minutes == 0)
                }
            }
            .onAppear {
                if let entry = existingEntry {
                    minutes = entry.completedMinutes
                    notes = entry.notes
                }
            }
        }
    }

    private func save() {
        habitVM.logTime(for: habit, minutes: minutes, notes: notes)
        if status == .completed {
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
        } else {
            dismiss()
        }
    }

    // MARK: - Sub views

    @ViewBuilder
    private func HabitHeaderCard() -> some View {
        HStack(spacing: 14) {
            Text(habit.emoji)
                .font(.system(size: 36))
                .frame(width: 56, height: 56)
                .background(habit.category.color.opacity(0.15))
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.hjText)
                Text("Daily target: \(habit.dailyTargetMinutes.toHoursMinutes)")
                    .font(.subheadline)
                    .foregroundColor(.hjSubtext)
            }
            Spacer()
        }
        .cardStyle()
    }
}

// MARK: - Time Input Section

private struct TimeInputSection: View {
    @Binding var minutes: Int
    let dailyTarget: Int

    private let presets = [5, 10, 15, 20, 30, 45, 60, 90]

    var body: some View {
        VStack(spacing: 20) {
            Text("How much did you complete today?")
                .font(.headline)
                .foregroundColor(.hjText)
                .multilineTextAlignment(.center)

            // Big time display
            VStack(spacing: 4) {
                Text(minutes > 0 ? minutes.toHoursMinutes : "0m")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(minutes > 0 ? .hjText : .hjSubtext)
                    .contentTransition(.numericText())

                Text("completed")
                    .font(.subheadline)
                    .foregroundColor(.hjSubtext)
            }

            // +/- controls
            HStack(spacing: 20) {
                ForEach([-15, -5], id: \.self) { delta in
                    AdjustButton(delta: delta, minutes: $minutes)
                }
                Spacer()
                ForEach([5, 15], id: \.self) { delta in
                    AdjustButton(delta: delta, minutes: $minutes)
                }
            }

            // Preset chips
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick select")
                    .font(.caption)
                    .foregroundColor(.hjSubtext)
                    .padding(.horizontal, 2)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // "Full target" button
                        if dailyTarget > 0 {
                            Button {
                                withAnimation { minutes = dailyTarget }
                            } label: {
                                VStack(spacing: 2) {
                                    Text("Full goal")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text(dailyTarget.toHoursMinutes)
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.hjGreen)
                                .cornerRadius(20)
                            }
                        }

                        ForEach(presets.filter { $0 != dailyTarget }, id: \.self) { preset in
                            Button {
                                withAnimation { minutes = preset }
                            } label: {
                                Text(preset.toHoursMinutes)
                                    .font(.system(size: 13, weight: minutes == preset ? .semibold : .regular))
                                    .foregroundColor(minutes == preset ? .white : .hjSubtext)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(minutes == preset ? Color.hjPrimary : Color.hjSurface2)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
}

private struct AdjustButton: View {
    let delta: Int
    @Binding var minutes: Int

    var body: some View {
        Button {
            withAnimation(.spring()) {
                minutes = max(0, minutes + delta)
            }
        } label: {
            VStack(spacing: 2) {
                Text(delta > 0 ? "+\(delta)" : "\(delta)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Text("min")
                    .font(.system(size: 10))
            }
            .foregroundColor(delta > 0 ? .hjPrimary : .hjSubtext)
            .frame(width: 54, height: 54)
            .background(delta > 0 ? Color.hjPrimary.opacity(0.12) : Color.hjSurface2)
            .cornerRadius(14)
        }
    }
}

// MARK: - Completion Preview

private struct CompletionPreviewCard: View {
    let status: CompletionStatus
    let percentage: Double
    let minutes: Int
    let targetMinutes: Int

    var body: some View {
        HStack(spacing: 16) {
            ProgressRingView(
                progress: min(percentage / 100, 1.0),
                size: 60,
                lineWidth: 6,
                color: status.color
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: status.icon)
                        .foregroundColor(status.color)
                    Text(statusMessage)
                        .font(.headline)
                        .foregroundColor(.hjText)
                }
                Text(detailMessage)
                    .font(.subheadline)
                    .foregroundColor(.hjSubtext)
            }
            Spacer()
        }
        .cardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(status.color.opacity(0.3), lineWidth: 1)
        )
    }

    private var statusMessage: String {
        switch status {
        case .completed: return "Goal Reached! 🎉"
        case .partial: return "Partial Progress"
        case .missed: return "Keep Going"
        case .none: return ""
        }
    }

    private var detailMessage: String {
        let remaining = max(0, targetMinutes - minutes)
        switch status {
        case .completed: return "You hit your daily target. Character moves forward!"
        case .partial: return "\(remaining.toHoursMinutes) more to reach your goal."
        case .missed: return "Every minute counts. \(Int(percentage))% of your daily goal."
        case .none: return ""
        }
    }
}

// MARK: - Notes Field

private struct NotesField: View {
    @Binding var notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes (optional)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.hjSubtext)

            TextEditor(text: $notes)
                .font(.body)
                .foregroundColor(.hjText)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: 70)
                .padding(12)
                .background(Color.hjSurface2)
                .cornerRadius(12)
        }
    }
}

// MARK: - Motivation Card

private struct MotivationCard: View {
    private let quotes = [
        "Every action you take is a vote for the type of person you wish to become.",
        "You do not rise to the level of your goals. You fall to the level of your systems.",
        "Small habits don't add up, they compound.",
        "The most effective form of motivation is progress.",
        "Success is the product of daily habits, not once-in-a-lifetime transformations.",
    ]
    @State private var quoteIndex = Int.random(in: 0..<5)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("💡 Atomic Habits")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.hjGold)
                .textCase(.uppercase)
                .tracking(0.6)
            Text("\"\(quotes[quoteIndex])\"")
                .font(.subheadline)
                .italic()
                .foregroundColor(.hjSubtext)
        }
        .cardStyle()
    }
}

// MARK: - Confetti

private struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = (0..<30).map { _ in ConfettiParticle() }

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Text(p.emoji)
                    .font(.system(size: p.size))
                    .position(x: p.x, y: p.y)
                    .opacity(p.opacity)
                    .rotationEffect(.degrees(p.rotation))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                for i in particles.indices {
                    particles[i].y -= CGFloat.random(in: 200...500)
                    particles[i].opacity = 0
                    particles[i].rotation += Double.random(in: -180...180)
                }
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat = CGFloat.random(in: 50...350)
    var y: CGFloat = CGFloat.random(in: 300...600)
    var size: CGFloat = CGFloat.random(in: 16...28)
    var opacity: Double = 1.0
    var rotation: Double = Double.random(in: -45...45)
    let emoji: String = ["🎉", "⭐", "✨", "🌟", "💫", "🎊"][Int.random(in: 0..<6)]
}
