import Foundation

enum AchievementType: String, Codable, CaseIterable {
    case streak3 = "streak3"
    case streak7 = "streak7"
    case streak21 = "streak21"
    case streak66 = "streak66"
    case streak100 = "streak100"
    case firstHabit = "firstHabit"
    case firstJournal = "firstJournal"
    case consistentWeek = "consistentWeek"
    case perfectDay = "perfectDay"
    case explorer = "explorer"
    case champion = "champion"

    var title: String {
        switch self {
        case .streak3: return "3 Day Streak"
        case .streak7: return "7 Day Streak"
        case .streak21: return "21 Day Streak"
        case .streak66: return "66 Day Streak"
        case .streak100: return "100 Day Streak"
        case .firstHabit: return "First Step"
        case .firstJournal: return "Inner Voice"
        case .consistentWeek: return "Full Week"
        case .perfectDay: return "Perfect Day"
        case .explorer: return "Explorer"
        case .champion: return "Champion"
        }
    }

    var description: String {
        switch self {
        case .streak3: return "3 consecutive days with a habit completed"
        case .streak7: return "A full week of showing up"
        case .streak21: return "21 days — habit is forming"
        case .streak66: return "66 days — science says it's automatic now"
        case .streak100: return "100 days — you're unstoppable"
        case .firstHabit: return "Created your very first habit"
        case .firstJournal: return "Wrote your first journal entry"
        case .consistentWeek: return "Completed habits all 7 days this week"
        case .perfectDay: return "All habits completed in a single day"
        case .explorer: return "Habits in 3 different categories"
        case .champion: return "Averaged 80%+ completion for a month"
        }
    }

    var emoji: String {
        switch self {
        case .streak3: return "🔥"
        case .streak7: return "⚡"
        case .streak21: return "🌱"
        case .streak66: return "💎"
        case .streak100: return "👑"
        case .firstHabit: return "🌟"
        case .firstJournal: return "📖"
        case .consistentWeek: return "✨"
        case .perfectDay: return "🏆"
        case .explorer: return "🗺️"
        case .champion: return "🎯"
        }
    }

    var pointValue: Int {
        switch self {
        case .streak3: return 50
        case .streak7: return 100
        case .streak21: return 250
        case .streak66: return 500
        case .streak100: return 1000
        case .firstHabit: return 25
        case .firstJournal: return 25
        case .consistentWeek: return 150
        case .perfectDay: return 100
        case .explorer: return 75
        case .champion: return 500
        }
    }
}

struct Achievement: Identifiable, Codable {
    var id: UUID
    var type: AchievementType
    var unlockedAt: Date

    init(type: AchievementType) {
        self.id = UUID()
        self.type = type
        self.unlockedAt = Date()
    }
}
