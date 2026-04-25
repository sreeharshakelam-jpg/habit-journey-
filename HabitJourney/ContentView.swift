import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var gameVM: GameViewModel

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Journey", systemImage: "map.fill") }
                    .tag(0)

                HabitListView()
                    .tabItem { Label("Habits", systemImage: "checkmark.circle.fill") }
                    .tag(1)

                JournalView()
                    .tabItem { Label("Journal", systemImage: "book.fill") }
                    .tag(2)

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.circle.fill") }
                    .tag(3)
            }
            .accentColor(.hjPrimary)

            if gameVM.showAchievementBanner, let achievement = gameVM.newAchievement {
                AchievementBannerView(achievement: achievement)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(999)
                    .padding(.top, 8)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: gameVM.showAchievementBanner)
    }
}
