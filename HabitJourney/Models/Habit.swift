import Foundation
import SwiftUI

enum HabitCategory: String, Codable, CaseIterable, Identifiable {
    case health = "Health"
    case learning = "Learning"
    case creativity = "Creativity"
    case fitness = "Fitness"
    case mindfulness = "Mindfulness"
    case social = "Social"
    case career = "Career"
    case other = "Other"

    var id: String { rawValue }

    var systemIcon: String {
        switch self {
        case .health: return "heart.fill"
        case .learning: return "book.fill"
        case .creativity: return "paintbrush.fill"
        case .fitness: return "figure.run"
        case .mindfulness: return "brain.head.profile"
        case .social: return "person.2.fill"
        case .career: return "briefcase.fill"
        case .other: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .health: return Color(red: 0.93, green: 0.36, blue: 0.36)
        case .learning: return Color(red: 0.29, green: 0.56, blue: 0.89)
        case .creativity: return Color(red: 0.72, green: 0.37, blue: 0.97)
        case .fitness: return Color(red: 0.27, green: 0.80, blue: 0.50)
        case .mindfulness: return Color(red: 0.20, green: 0.76, blue: 0.70)
        case .social: return Color(red: 0.96, green: 0.62, blue: 0.24)
        case .career: return Color(red: 0.42, green: 0.47, blue: 0.95)
        case .other: return Color(red: 0.60, green: 0.60, blue: 0.70)
        }
    }
}

struct Habit: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var category: HabitCategory
    var targetMinutesPerWeek: Int
    var emoji: String
    var createdAt: Date
    var isActive: Bool

    var dailyTargetMinutes: Int { targetMinutesPerWeek / 7 }

    var targetDescription: String {
        let h = targetMinutesPerWeek / 60
        let m = targetMinutesPerWeek % 60
        if h > 0 && m > 0 { return "\(h)h \(m)m/week" }
        if h > 0 { return "\(h)h/week" }
        return "\(m)m/week"
    }

    init(name: String, category: HabitCategory, targetMinutesPerWeek: Int, emoji: String = "⭐") {
        self.id = UUID()
        self.name = name
        self.category = category
        self.targetMinutesPerWeek = targetMinutesPerWeek
        self.emoji = emoji
        self.createdAt = Date()
        self.isActive = true
    }
}
