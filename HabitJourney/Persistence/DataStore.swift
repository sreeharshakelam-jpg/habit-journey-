import Foundation
import Combine

class DataStore: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var habitEntries: [HabitEntry] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var userProfile: UserProfile = UserProfile()

    private let habitsKey = "hj_habits_v1"
    private let entriesKey = "hj_entries_v1"
    private let journalKey = "hj_journal_v1"
    private let profileKey = "hj_profile_v1"

    init() { load() }

    func load() {
        habits = decode([Habit].self, from: habitsKey) ?? []
        habitEntries = decode([HabitEntry].self, from: entriesKey) ?? []
        journalEntries = decode([JournalEntry].self, from: journalKey) ?? []
        userProfile = decode(UserProfile.self, from: profileKey) ?? UserProfile()
    }

    private func save() {
        encode(habits, for: habitsKey)
        encode(habitEntries, for: entriesKey)
        encode(journalEntries, for: journalKey)
        encode(userProfile, for: profileKey)
    }

    private func decode<T: Codable>(_ type: T.Type, from key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func encode<T: Codable>(_ value: T, for key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: Habits

    func addHabit(_ habit: Habit) {
        habits.append(habit)
        save()
    }

    func updateHabit(_ habit: Habit) {
        guard let i = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[i] = habit
        save()
    }

    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        habitEntries.removeAll { $0.habitId == habit.id }
        save()
    }

    // MARK: Entries

    func addEntry(_ entry: HabitEntry) {
        habitEntries.removeAll { $0.habitId == entry.habitId && $0.dateKey == entry.dateKey }
        habitEntries.append(entry)
        save()
    }

    func entry(for habit: Habit, on date: Date) -> HabitEntry? {
        let key = dateKey(from: date)
        return habitEntries.first { $0.habitId == habit.id && $0.dateKey == key }
    }

    func entries(for habit: Habit, from start: Date, to end: Date) -> [HabitEntry] {
        habitEntries.filter { $0.habitId == habit.id && $0.date >= start && $0.date <= end }
    }

    func allEntries(on date: Date) -> [HabitEntry] {
        let key = dateKey(from: date)
        return habitEntries.filter { $0.dateKey == key }
    }

    // MARK: Journal

    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.dateKey == entry.dateKey }
        journalEntries.append(entry)
        save()
    }

    func journalEntry(for date: Date) -> JournalEntry? {
        let key = dateKey(from: date)
        return journalEntries.first { $0.dateKey == key }
    }

    // MARK: Profile

    func updateProfile(_ profile: UserProfile) {
        userProfile = profile
        save()
    }

    // MARK: Helpers

    private func dateKey(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
