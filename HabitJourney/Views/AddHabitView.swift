import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @EnvironmentObject var gameVM: GameViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var selectedCategory: HabitCategory = .health
    @State private var selectedEmoji: String = "⭐"
    @State private var targetHours: Int = 1
    @State private var targetMinutes: Int = 0
    @State private var showEmojiPicker = false

    private let emojiOptions = ["⭐", "🏃", "📚", "🎨", "🧘", "💪", "🥗", "✍️", "🎵", "💻", "🌿", "🎯", "🧪", "🤝", "🌅", "🧠", "🏊", "🎸", "📝", "🦋"]

    private var totalMinutes: Int { targetHours * 60 + targetMinutes }
    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && totalMinutes > 0 }

    var body: some View {
        NavigationView {
            ZStack {
                Color.hjBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Emoji & Name
                        VStack(spacing: 16) {
                            SectionHeader("Habit Identity")

                            HStack(spacing: 12) {
                                Button {
                                    showEmojiPicker.toggle()
                                } label: {
                                    Text(selectedEmoji)
                                        .font(.system(size: 32))
                                        .frame(width: 60, height: 60)
                                        .background(selectedCategory.color.opacity(0.15))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(selectedCategory.color.opacity(0.4), lineWidth: 1.5)
                                        )
                                }

                                TextField("Habit name...", text: $name)
                                    .font(.headline)
                                    .foregroundColor(.hjText)
                                    .padding(14)
                                    .background(Color.hjSurface2)
                                    .cornerRadius(12)
                            }

                            if showEmojiPicker {
                                EmojiPickerGrid(options: emojiOptions, selected: $selectedEmoji) {
                                    showEmojiPicker = false
                                }
                            }
                        }
                        .cardStyle()

                        // Category
                        VStack(spacing: 16) {
                            SectionHeader("Category")

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                                ForEach(HabitCategory.allCases) { cat in
                                    CategoryOptionButton(category: cat, isSelected: selectedCategory == cat) {
                                        withAnimation(.spring()) { selectedCategory = cat }
                                    }
                                }
                            }
                        }
                        .cardStyle()

                        // Weekly Target
                        VStack(spacing: 20) {
                            SectionHeader("Weekly Target")

                            VStack(spacing: 6) {
                                Text(totalMinutes > 0 ? totalMinutes.toHoursMinutes + " per week" : "Set your target")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(totalMinutes > 0 ? .hjText : .hjSubtext)

                                Text("Daily: \(totalMinutes > 0 ? (totalMinutes / 7).toHoursMinutes : "—")")
                                    .font(.caption)
                                    .foregroundColor(.hjSubtext)
                            }

                            HStack(spacing: 24) {
                                StepperControl(label: "Hours", value: $targetHours, range: 0...23)
                                StepperControl(label: "Minutes", value: $targetMinutes, range: 0...55, step: 5)
                            }

                            // Quick presets
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quick presets")
                                    .font(.caption)
                                    .foregroundColor(.hjSubtext)
                                HStack(spacing: 8) {
                                    ForEach([30, 60, 150, 300, 420], id: \.self) { mins in
                                        PresetButton(label: mins.toHoursMinutes, isSelected: totalMinutes == mins) {
                                            targetHours = mins / 60
                                            targetMinutes = mins % 60
                                        }
                                    }
                                }
                            }
                        }
                        .cardStyle()

                        // Atomic Habits tip
                        AtomicHabitsTip()

                        Spacer(minLength: 24)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.hjSubtext)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let habit = Habit(
                            name: name.trimmingCharacters(in: .whitespaces),
                            category: selectedCategory,
                            targetMinutesPerWeek: totalMinutes,
                            emoji: selectedEmoji
                        )
                        habitVM.addHabit(habit)
                        gameVM.recalculate()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(isValid ? .hjPrimary : .hjSubtext)
                    .disabled(!isValid)
                }
            }
        }
    }
}

// MARK: - Sub-components

private struct SectionHeader: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack {
            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.hjSubtext)
                .textCase(.uppercase)
                .tracking(0.8)
            Spacer()
        }
    }
}

private struct CategoryOptionButton: View {
    let category: HabitCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? category.color : category.color.opacity(0.1))
                        .frame(width: 52, height: 52)
                    Image(systemName: category.systemIcon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : category.color)
                }
                Text(category.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? category.color : .hjSubtext)
                    .lineLimit(1)
            }
        }
    }
}

private struct StepperControl: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var step: Int = 1

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.hjSubtext)
            HStack(spacing: 16) {
                Button {
                    if value - step >= range.lowerBound { value -= step }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(value > range.lowerBound ? .hjPrimary : .hjSurface2)
                }

                Text("\(value)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.hjText)
                    .frame(width: 44)

                Button {
                    if value + step <= range.upperBound { value += step }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(value < range.upperBound ? .hjPrimary : .hjSurface2)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.hjSurface2)
        .cornerRadius(12)
    }
}

private struct PresetButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .hjSubtext)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.hjPrimary : Color.hjSurface2)
                .cornerRadius(20)
        }
    }
}

private struct EmojiPickerGrid: View {
    let options: [String]
    @Binding var selected: String
    let onSelect: () -> Void

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
            ForEach(options, id: \.self) { emoji in
                Button {
                    selected = emoji
                    onSelect()
                } label: {
                    Text(emoji)
                        .font(.system(size: 28))
                        .frame(width: 50, height: 50)
                        .background(selected == emoji ? Color.hjPrimary.opacity(0.2) : Color.hjSurface2)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selected == emoji ? Color.hjPrimary : Color.clear, lineWidth: 1.5)
                        )
                }
            }
        }
    }
}

private struct AtomicHabitsTip: View {
    private let tips = [
        ("🔗", "Habit Stacking", "Link your new habit to something you already do daily."),
        ("🎯", "2-Minute Rule", "Start with just 2 minutes. Make it ridiculously easy."),
        ("🌍", "Environment Design", "Set up your space to make the habit obvious and easy."),
    ]

    @State private var tipIndex = 0

    var body: some View {
        let tip = tips[tipIndex]
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(tip.0)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Atomic Habits Tip")
                        .font(.caption)
                        .foregroundColor(.hjGold)
                        .textCase(.uppercase)
                        .tracking(0.6)
                    Text(tip.1)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.hjText)
                }
                Spacer()
                Button {
                    withAnimation { tipIndex = (tipIndex + 1) % tips.count }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.hjSubtext)
                }
            }
            Text(tip.2)
                .font(.subheadline)
                .foregroundColor(.hjSubtext)
        }
        .cardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.hjGold.opacity(0.2), lineWidth: 1)
        )
    }
}
