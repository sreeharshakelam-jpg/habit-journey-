import Foundation

enum Mood: String, Codable, CaseIterable, Identifiable {
    case amazing = "Amazing"
    case good = "Good"
    case okay = "Okay"
    case tough = "Tough"
    case bad = "Bad"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .amazing: return "🌟"
        case .good: return "😊"
        case .okay: return "😐"
        case .tough: return "😔"
        case .bad: return "😞"
        }
    }

    var score: Int {
        switch self { case .amazing: return 5; case .good: return 4; case .okay: return 3; case .tough: return 2; case .bad: return 1 }
    }
}

struct JournalEntry: Identifiable, Codable {
    var id: UUID
    var date: Date
    var content: String
    var mood: Mood
    var gratitude: [String]
    var intention: String

    var dateKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    init(date: Date = Date(), content: String, mood: Mood, gratitude: [String] = [], intention: String = "") {
        self.id = UUID()
        self.date = date
        self.content = content
        self.mood = mood
        self.gratitude = gratitude
        self.intention = intention
    }
}
