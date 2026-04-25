import Foundation
import Combine
import SwiftUI

class GameViewModel: ObservableObject {
    private let dataStore: DataStore
    private var cancellables = Set<AnyCancellable>()

    @Published var userProfile: UserProfile
    @Published var newAchievement: Achievement? = nil
    @Published var showAchievementBanner: Bool = false
    @Published var characterPosition: Double = 0.0

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        self.userProfile = dataStore.userProfile
        self.characterPosition = dataStore.userProfile.characterPosition

        dataStore.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.userProfile = profile
            }
            .store(in: &cancellables)

        dataStore.$habitEntries
            .receive(on: DispatchQueue.main)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.recalculate() }
            .store(in: &cancellables)

        dataStore.$habits
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.checkAchievements() }
            .store(in: &cancellables)

        dataStore.$journalEntries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.checkAchievements() }
            .store(in: &cancellables)
    }

    func recalculate() {
        updateStreak()
        updateCharacterPosition()
        checkAchievements()
    }

    private func updateStreak() {
        let cal = Calendar.current
        var streak = 0
        var date = cal.startOfDay(for: Date())

        while streak < 365 {
            let anyEntry = dataStore.habits.contains { habit in
                if let e = dataStore.entry(for: habit, on: date) {
                    return e.completedMinutes > 0
                }
                return false
            }
            if anyEntry {
                streak += 1
                date = cal.date(byAdding: .day, value: -1, to: date) ?? date
            } else {
                break
            }
        }

        var profile = dataStore.userProfile
        profile.currentStreak = streak
        profile.longestStreak = max(profile.longestStreak, streak)
        dataStore.updateProfile(profile)
    }

    private func updateCharacterPosition() {
        let uniqueDays = Set(dataStore.habitEntries.filter { $0.completedMinutes > 0 }.map { $0.dateKey }).count
        let newPos = min(1.0, Double(uniqueDays) * 0.025)

        withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
            characterPosition = newPos
        }

        var profile = dataStore.userProfile
        profile.characterPosition = newPos
        dataStore.updateProfile(profile)
    }

    private func checkAchievements() {
        var profile = dataStore.userProfile
        let existingTypes = Set(profile.achievements.map { $0.type })
        var earned: [Achievement] = []

        func check(_ type: AchievementType, _ condition: Bool) {
            if condition && !existingTypes.contains(type) {
                earned.append(Achievement(type: type))
            }
        }

        let streak = profile.currentStreak
        check(.streak3, streak >= 3)
        check(.streak7, streak >= 7)
        check(.streak21, streak >= 21)
        check(.streak66, streak >= 66)
        check(.streak100, streak >= 100)
        check(.firstHabit, !dataStore.habits.isEmpty)
        check(.firstJournal, !dataStore.journalEntries.isEmpty)
        check(.explorer, Set(dataStore.habits.map { $0.category }).count >= 3)

        // Perfect day: all active habits logged with 80%+ today
        let todayStatuses = dataStore.habits.compactMap { habit -> CompletionStatus? in
            guard let e = dataStore.entry(for: habit, on: Date()) else { return nil }
            return e.completionStatus(for: habit)
        }
        check(.perfectDay, !todayStatuses.isEmpty && todayStatuses.allSatisfy { $0 == .completed })

        // Consistent week
        let cal = Calendar.current
        if let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) {
            let days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: weekStart) }
            let completedDays = days.filter { day in
                dataStore.habits.contains { habit in
                    dataStore.entry(for: habit, on: day)?.completedMinutes ?? 0 > 0
                }
            }
            check(.consistentWeek, completedDays.count >= 7)
        }

        if !earned.isEmpty {
            let points = earned.reduce(0) { $0 + $1.type.pointValue }
            profile.achievements.append(contentsOf: earned)
            profile.addPoints(points)
            dataStore.updateProfile(profile)

            newAchievement = earned.first
            withAnimation(.spring()) { showAchievementBanner = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeOut) { self.showAchievementBanner = false }
            }
        }
    }

    func awardPoints(_ points: Int) {
        var profile = dataStore.userProfile
        profile.addPoints(points)
        dataStore.updateProfile(profile)
    }

    func updateName(_ name: String) {
        var profile = dataStore.userProfile
        profile.name = name
        dataStore.updateProfile(profile)
    }

    func updateJournalReminder(enabled: Bool, hour: Int, minute: Int) {
        var profile = dataStore.userProfile
        profile.journalReminderEnabled = enabled
        profile.journalReminderHour = hour
        profile.journalReminderMinute = minute
        dataStore.updateProfile(profile)
    }
}
