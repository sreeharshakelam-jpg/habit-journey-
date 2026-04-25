import Foundation
import Combine

class JournalViewModel: ObservableObject {
    private let dataStore: DataStore
    private var cancellables = Set<AnyCancellable>()

    @Published var entries: [JournalEntry] = []
    @Published var todayEntry: JournalEntry? = nil

    init(dataStore: DataStore) {
        self.dataStore = dataStore

        dataStore.$journalEntries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entries in
                self?.entries = entries.sorted { $0.date > $1.date }
                self?.todayEntry = self?.dataStore.journalEntry(for: Date())
            }
            .store(in: &cancellables)

        entries = dataStore.journalEntries.sorted { $0.date > $1.date }
        todayEntry = dataStore.journalEntry(for: Date())
    }

    func save(_ entry: JournalEntry) {
        dataStore.addJournalEntry(entry)
    }

    func entry(for date: Date) -> JournalEntry? {
        dataStore.journalEntry(for: date)
    }

    var moodTrend: [Mood] {
        entries.prefix(7).compactMap { $0.mood }.reversed()
    }
}
