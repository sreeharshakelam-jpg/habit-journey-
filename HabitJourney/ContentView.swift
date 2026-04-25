import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var gameVM: GameViewModel

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Ritual", systemImage: "sun.max.fill") }
                    .tag(0)

                JourneyView()
                    .tabItem { Label("Journey", systemImage: "map.fill") }
                    .tag(1)

                HabitListView()
                    .tabItem { Label("Forge", systemImage: "hammer.fill") }
                    .tag(2)

                JournalView()
                    .tabItem { Label("Virtues", systemImage: "book.fill") }
                    .tag(3)

                MentorView()
                    .tabItem { Label("Mentor", systemImage: "person.fill.questionmark") }
                    .tag(4)
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
