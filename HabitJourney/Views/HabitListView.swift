import SwiftUI

struct HabitListView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @EnvironmentObject var gameVM: GameViewModel
    @State private var showAdd = false
    @State private var selectedCategory: HabitCategory? = nil

    private var filteredHabits: [Habit] {
        guard let cat = selectedCategory else { return habitVM.habits }
        return habitVM.habits.filter { $0.category == cat }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.hjBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Category filter
                        CategoryFilterRow(selected: $selectedCategory)
                            .padding(.top, 8)

                        // Habit cards
                        if filteredHabits.isEmpty {
                            EmptyStateView(
                                emoji: selectedCategory != nil ? "🔍" : "✨",
                                title: selectedCategory != nil ? "No habits here" : "No habits yet",
                                message: selectedCategory != nil
                                    ? "Try a different category or add a new habit."
                                    : "Tap + to create your first habit. Remember: tiny changes lead to remarkable results."
                            )
                            .padding(.top, 40)
                        } else {
                            ForEach(filteredHabits) { habit in
                                HabitCardView(habit: habit)
                                    .environmentObject(habitVM)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            habitVM.deleteHabit(habit)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }

                        // Weekly overview
                        if !habitVM.habits.isEmpty {
                            WeeklyOverviewSection()
                                .padding(.top, 8)
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("My Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.hjPrimary)
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddHabitView()
                    .environmentObject(habitVM)
                    .environmentObject(gameVM)
            }
        }
    }
}

// MARK: - Category Filter

private struct CategoryFilterRow: View {
    @Binding var selected: HabitCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", isSelected: selected == nil) {
                    selected = nil
                }
                ForEach(HabitCategory.allCases) { cat in
                    FilterChip(
                        label: cat.rawValue,
                        icon: cat.systemIcon,
                        color: cat.color,
                        isSelected: selected == cat
                    ) {
                        selected = selected == cat ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct FilterChip: View {
    let label: String
    var icon: String? = nil
    var color: Color = .hjPrimary
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                }
                Text(label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isSelected ? color : color.opacity(0.12))
            .cornerRadius(20)
        }
    }
}

// MARK: - Weekly Overview

private struct WeeklyOverviewSection: View {
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.hjText)

            HStack(spacing: 0) {
                ForEach(weekDays(), id: \.0) { (label, date) in
                    let hasEntry = habitVM.habits.contains { habit in
                        habitVM.todayEntry(for: habit) != nil && Calendar.current.isDate(date, inSameDayAs: Date())
                    }
                    VStack(spacing: 6) {
                        Text(label)
                            .font(.system(size: 11))
                            .foregroundColor(.hjSubtext)
                        Circle()
                            .fill(dayColor(for: date))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(dayNumber(date))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Calendar.current.isDateInToday(date) ? .white : .hjSubtext)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .cardStyle()
    }

    private func weekDays() -> [(String, Date)] {
        let cal = Calendar.current
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return [] }
        return (0..<7).compactMap { offset in
            guard let d = cal.date(byAdding: .day, value: offset, to: weekStart) else { return nil }
            let f = DateFormatter()
            f.dateFormat = "EEE"
            return (f.string(from: d), d)
        }
    }

    private func dayColor(for date: Date) -> Color {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return Color.hjPrimary }
        if date > Date() { return Color.hjSurface2 }
        let hasEntry = habitVM.habits.contains {
            habitVM.todayEntry(for: $0) != nil && cal.isDate(date, inSameDayAs: Date())
        }
        return hasEntry ? Color.hjGreen.opacity(0.6) : Color.hjSurface2
    }

    private func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let emoji: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Text(emoji).font(.system(size: 56))
            Text(title)
                .font(.headline)
                .foregroundColor(.hjText)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.hjSubtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }
}
