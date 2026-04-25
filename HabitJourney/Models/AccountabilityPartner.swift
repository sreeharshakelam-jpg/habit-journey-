import Foundation

// Accountability partner model — placeholder for future social features.
// Partners can view your streak and cheer you on; full implementation in a future release.

struct AccountabilityPartner: Identifiable, Codable {
    var id: UUID
    var name: String
    var emoji: String
    var addedAt: Date

    init(name: String, emoji: String = "👤") {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.addedAt = Date()
    }
}
