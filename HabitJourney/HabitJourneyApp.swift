import SwiftUI

@main
struct HabitJourneyApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState.habitVM)
                .environmentObject(appState.journalVM)
                .environmentObject(appState.gameVM)
                .environmentObject(NotificationManager.shared)
                .preferredColorScheme(.dark)
                .onAppear {
                    NotificationManager.shared.requestPermission()
                    appState.gameVM.recalculate()
                }
        }
    }
}
