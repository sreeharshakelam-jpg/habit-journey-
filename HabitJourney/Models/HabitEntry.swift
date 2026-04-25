import Foundation
import SwiftUI

enum CompletionStatus: String, Codable {
    case completed = "Completed"
    case partial = "Partial"
    case missed = "Missed"
    case none = "None"

    var color: Color {
        switch self {
        case .completed: return Color(red: 0.27, green: 0.80, blue: 0.50)
        case .partial: return Color(red: 0.96, green: 0.75, blue: 0.24)
        case .missed: return Color(red: 0.93, green: 0.36, blue: 0.36)
        case .none: return Color.white.opacity(0.15)
        }
    }

    var icon: String {
        switch self {
        case .completed: return "checkmark.circle.fill"
        case .partial: return "circle.lefthalf.filled"
        case .missed: return "xmark.circle.fill"
        case .none: return "circle"
        }
    }

    var label: String { rawValue }

    var characterMoveAmount: Double {
        switch self {
        case .completed: return 1.0
        case .partial: return 0.4
        case .missed: return 0.0
        case .none: return 0.0
        }
    }
}

struct HabitEntry: Identifiable, Codable {
    var id: UUID
    var habitId: UUID
    var date: Date
    var completedMinutes: Int
    var notes: String

    var dateKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    func completionPercentage(for habit: Habit) -> Double {
        guard habit.dailyTargetMinutes > 0 else { return 0 }
        return min(Double(completedMinutes) / Double(habit.dailyTargetMinutes) * 100, 100)
    }

    func completionStatus(for habit: Habit) -> CompletionStatus {
        let pct = completionPercentage(for: habit)
        if pct >= 80 { return .completed }
        if pct >= 50 { return .partial }
        return .missed
    }

    init(habitId: UUID, date: Date = Date(), completedMinutes: Int, notes: String = "") {
        self.id = UUID()
        self.habitId = habitId
        self.date = date
        self.completedMinutes = completedMinutes
        self.notes = notes
    }
}
