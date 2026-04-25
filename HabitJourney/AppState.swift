import Foundation

class AppState: ObservableObject {
    let dataStore = DataStore()

    lazy var habitVM: HabitViewModel = HabitViewModel(dataStore: dataStore)
    lazy var journalVM: JournalViewModel = JournalViewModel(dataStore: dataStore)
    lazy var gameVM: GameViewModel = GameViewModel(dataStore: dataStore)
}
