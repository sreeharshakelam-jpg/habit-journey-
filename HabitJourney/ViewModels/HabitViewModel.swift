import Foundation
import Combine
import SwiftUI

class HabitViewModel: ObservableObject {
    private let dataStore: DataStore
    private var cancellables = Set<AnyCancellable>()

    @Published var habits: [Habit] = []
    @Published var todayEntries: [UUID: HabitEntry] = [:]
    @Published var weeklyStats: [UUID: WeeklyStats] = [:]
    @Published var goalSuggestions: [GoalSuggestion] = []

    struct WeeklyStats {
        var completedMinutes: Int
        var targetMinutes: Int
        var completionPercentage: Double
        var daysLogged: Int
    }

    struct GoalSuggestion: Identifiable {
        var id = UUID()
        var habitId: UUID
        var habitName: String
        var currentTarget: Int
        var suggestedTarget: Int
        var reason: String
        var isIncrease: Bool
    }

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        setupBindings()
        refresh()
    }

    private func setupBindings() {
        dataStore.$habits
            .receive(on: DispatchQueue.main)
            .sink { [weak self] habits in
                self?.habits = habits
                self?.refreshStats()
                self?.checkSuggestions()
            }
            .store(in: &cancellables)

        dataStore.$habitEntries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshTodayEntries()
                self?.refreshStats()
                self?.checkSuggestions()
            }
            .store(in: &cancellables)
    }

    func refresh() {
        habits = dataStore.habits
        refreshTodayEntries()
        refreshStats()
        checkSuggestions()
    }

    private func refreshTodayEntries() {
        var map: [UUID: HabitEntry] = [:]
        for habit in dataStore.habits {
            if let e = dataStore.entry(for: habit, on: Date()) {
                map[habit.id] = e
            }
        }
        todayEntries = map
    }

    private func refreshStats() {
        let cal = Calendar.current
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())),
              let weekEnd = cal.date(byAdding: .day, value: 6, to: weekStart) else { return }

        var stats: [UUID: WeeklyStats] = [:]
        for habit in dataStore.habits {
            let entries = dataStore.entries(for: habit, from: weekStart, to: weekEnd)
            let completed = entries.reduce(0) { $0 + $1.completedMinutes }
            let pct = habit.targetMinutesPerWeek > 0
                ? min(Double(completed) / Double(habit.targetMinutesPerWeek) * 100, 100)
                : 0
            stats[habit.id] = WeeklyStats(
                completedMinutes: completed,
                targetMinutes: habit.targetMinutesPerWeek,
                completionPercentage: pct,
                daysLogged: entries.count
            )
        }
        weeklyStats = stats
    }

    private func checkSuggestions() {
        let cal = Calendar.current
        var suggestions: [GoalSuggestion] = []

        for habit in dataStore.habits {
            var weekPcts: [Double] = []
            for offset in 1...4 {
                guard let wStart = cal.date(byAdding: .weekOfYear, value: -offset, to: Date()),
                      let wEnd = cal.date(byAdding: .day, value: 6, to: wStart) else { continue }
                let entries = dataStore.entries(for: habit, from: wStart, to: wEnd)
                let completed = entries.reduce(0) { $0 + $1.completedMinutes }
                let pct = Double(completed) / Double(max(1, habit.targetMinutesPerWeek)) * 100
                weekPcts.append(pct)
            }
            guard weekPcts.count >= 2 else { continue }
            let avg = weekPcts.reduce(0, +) / Double(weekPcts.count)

            if avg < 50 {
                let suggested = max(30, Int(Double(habit.targetMinutesPerWeek) * 0.7))
                suggestions.append(GoalSuggestion(
                    habitId: habit.id,
                    habitName: habit.name,
                    currentTarget: habit.targetMinutesPerWeek,
                    suggestedTarget: suggested,
                    reason: "You've averaged \(Int(avg))% of your goal. A smaller target builds momentum — 1% better each day.",
                    isIncrease: false
                ))
            } else if avg > 95 {
                let suggested = Int(Double(habit.targetMinutesPerWeek) * 1.2)
                suggestions.append(GoalSuggestion(
                    habitId: habit.id,
                    habitName: habit.name,
                    currentTarget: habit.targetMinutesPerWeek,
                    suggestedTarget: suggested,
                    reason: "You're crushing it at \(Int(avg))%! Ready to raise the bar?",
                    isIncrease: true
                ))
            }
        }
        goalSuggestions = suggestions
    }

    // MARK: Actions

    func addHabit(_ habit: Habit) { dataStore.addHabit(habit) }
    func updateHabit(_ habit: Habit) { dataStore.updateHabit(habit) }
    func deleteHabit(_ habit: Habit) { dataStore.deleteHabit(habit) }

    func logTime(for habit: Habit, minutes: Int, notes: String = "") {
        let entry = HabitEntry(habitId: habit.id, completedMinutes: minutes, notes: notes)
        dataStore.addEntry(entry)
    }

    func applySuggestion(_ suggestion: GoalSuggestion) {
        if var habit = habits.first(where: { $0.id == suggestion.habitId }) {
            habit.targetMinutesPerWeek = suggestion.suggestedTarget
            updateHabit(habit)
        }
        goalSuggestions.removeAll { $0.id == suggestion.id }
    }

    func dismissSuggestion(_ suggestion: GoalSuggestion) {
        goalSuggestions.removeAll { $0.id == suggestion.id }
    }

    // MARK: Queries

    func todayEntry(for habit: Habit) -> HabitEntry? { todayEntries[habit.id] }

    func completionStatus(for habit: Habit) -> CompletionStatus {
        guard let e = todayEntry(for: habit) else { return .none }
        return e.completionStatus(for: habit)
    }

    func weeklyCompletionPercentage(for habit: Habit) -> Double {
        weeklyStats[habit.id]?.completionPercentage ?? 0
    }

    func weeklyCompletedMinutes(for habit: Habit) -> Int {
        weeklyStats[habit.id]?.completedMinutes ?? 0
    }

    var overallTodayStatus: CompletionStatus {
        let statuses = habits.map { completionStatus(for: $0) }.filter { $0 != .none }
        if statuses.isEmpty { return .none }
        if statuses.allSatisfy({ $0 == .completed }) { return .completed }
        if statuses.contains(.completed) || statuses.contains(.partial) { return .partial }
        return .missed
    }

    var habits30DayHistory: [(date: Date, hasEntry: Bool)] {
        let cal = Calendar.current
        return (0..<30).compactMap { offset in
            guard let date = cal.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let hasEntry = habits.contains { dataStore.entry(for: $0, on: date) != nil }
            return (date: date, hasEntry: hasEntry)
        }.reversed()
    }

    func hasAnyEntry(on date: Date) -> Bool {
        habits.contains { dataStore.entry(for: $0, on: date) != nil }
    }
}
