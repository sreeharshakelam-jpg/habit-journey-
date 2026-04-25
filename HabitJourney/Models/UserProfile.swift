import Foundation

struct UserProfile: Codable {
    var name: String
    var totalPoints: Int
    var currentStreak: Int
    var longestStreak: Int
    var characterPosition: Double
    var level: Int
    var achievements: [Achievement]
    var journalReminderEnabled: Bool
    var journalReminderHour: Int
    var journalReminderMinute: Int
    var lastActiveDateKey: String?

    var levelTitle: String {
        switch level {
        case 1: return "Seedling"
        case 2: return "Sprout"
        case 3: return "Sapling"
        case 4: return "Explorer"
        case 5: return "Wanderer"
        case 6: return "Adventurer"
        case 7: return "Champion"
        case 8: return "Legend"
        case 9: return "Titan"
        default: return level >= 10 ? "Master" : "Seedling"
        }
    }

    var levelProgress: Double {
        let base = (level - 1) * 200
        let cap = level * 200
        guard cap > base else { return 1 }
        return Double(totalPoints - base) / Double(cap - base)
    }

    var pointsToNextLevel: Int { max(0, level * 200 - totalPoints) }

    mutating func addPoints(_ points: Int) {
        totalPoints += points
        level = max(1, totalPoints / 200 + 1)
    }

    init(name: String = "Hero") {
        self.name = name
        self.totalPoints = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.characterPosition = 0.0
        self.level = 1
        self.achievements = []
        self.journalReminderEnabled = false
        self.journalReminderHour = 21
        self.journalReminderMinute = 0
        self.lastActiveDateKey = nil
    }
}
