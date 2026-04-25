import SwiftUI

// MARK: - Main View

struct JourneyView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var habitVM: HabitViewModel
    @State private var selectedTab: JourneyTab = .path

    enum JourneyTab: String, CaseIterable {
        case path = "Path"
        case chain = "Chain"
        case partners = "Partners"
        case laws = "4 Laws"

        var icon: String {
            switch self {
            case .path:     return "map.fill"
            case .chain:    return "link"
            case .partners: return "person.2.fill"
            case .laws:     return "book.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            Color.hjBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                JourneyHeroHeader()

                JourneyTabPills(selected: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                ScrollView(showsIndicators: false) {
                    Group {
                        switch selectedTab {
                        case .path:     JourneyPathTab()
                        case .chain:    JourneyChainTab()
                        case .partners: JourneyPartnersTab()
                        case .laws:     JourneyLawsTab()
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Hero Header

private struct JourneyHeroHeader: View {
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(red: 0.18, green: 0.10, blue: 0.42), Color.hjBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient.primaryGradient)
                            .frame(width: 58, height: 58)
                            .shadow(color: Color.hjPrimary.opacity(0.55), radius: 10)
                        Text("🔥")
                            .font(.system(size: 26))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(gameVM.userProfile.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.hjText)

                        HStack(spacing: 6) {
                            Text("Lv. \(gameVM.userProfile.level)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(LinearGradient.primaryGradient)
                                .cornerRadius(10)

                            Text(gameVM.userProfile.levelTitle)
                                .font(.caption)
                                .foregroundColor(.hjPrimaryLight)
                        }
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("\(gameVM.userProfile.totalPoints)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.hjGold)
                        Text("pts")
                            .font(.caption2)
                            .foregroundColor(.hjSubtext)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.hjGold.opacity(0.12))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hjGold.opacity(0.3), lineWidth: 1))
                }

                HStack(spacing: 0) {
                    JourneyStatPill(icon: "flame.fill",           value: "\(gameVM.userProfile.currentStreak)",        label: "Streak",  color: .orange)
                    Rectangle().fill(Color.hjSurface2).frame(width: 1, height: 28)
                    JourneyStatPill(icon: "checkmark.circle.fill", value: "\(habitVM.habits.count)",                   label: "Habits",  color: .hjGreen)
                    Rectangle().fill(Color.hjSurface2).frame(width: 1, height: 28)
                    JourneyStatPill(icon: "crown.fill",            value: "\(gameVM.userProfile.longestStreak)d",      label: "Best",    color: .hjGold)
                    Rectangle().fill(Color.hjSurface2).frame(width: 1, height: 28)
                    JourneyStatPill(icon: "map.fill",              value: "\(Int(gameVM.characterPosition * 100))%",   label: "Journey", color: .hjPrimaryLight)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.hjSurface.opacity(0.8))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.hjPrimary.opacity(0.2), lineWidth: 1))
            }
            .padding(.horizontal, 16)
            .padding(.top, 56)
            .padding(.bottom, 16)
        }
    }
}

private struct JourneyStatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 11)).foregroundColor(color)
                Text(value).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.hjText)
            }
            Text(label).font(.caption2).foregroundColor(.hjSubtext)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Pill Tab Bar

private struct JourneyTabPills: View {
    @Binding var selected: JourneyView.JourneyTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(JourneyView.JourneyTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selected = tab }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.icon).font(.system(size: 11, weight: .semibold))
                        Text(tab.rawValue).font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(
                        selected == tab
                            ? AnyView(LinearGradient.primaryGradient)
                            : AnyView(Color.hjSurface)
                    )
                    .foregroundColor(selected == tab ? .white : .hjSubtext)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(selected == tab ? Color.clear : Color.hjSurface2, lineWidth: 1))
                    .shadow(color: selected == tab ? Color.hjPrimary.opacity(0.4) : .clear, radius: 6)
                }
            }
        }
    }
}

// MARK: - Path Tab

private struct JourneyPathTab: View {
    @EnvironmentObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.hjSurface)
                    .shadow(color: Color.hjPrimary.opacity(0.12), radius: 12)
                JourneyPathView(characterPosition: gameVM.characterPosition)
                    .padding(12)
            }
            .frame(height: 320)
            .padding(.horizontal, 16)

            HStack(spacing: 12) {
                PathInfoCard(
                    title: "Progress",
                    value: "\(Int(gameVM.characterPosition * 100))%",
                    subtitle: "of journey complete",
                    icon: "map.fill",
                    gradient: .primaryGradient
                )
                PathInfoCard(
                    title: "Milestones",
                    value: "\(Int(gameVM.characterPosition * 7))/7",
                    subtitle: "reached",
                    icon: "star.fill",
                    gradient: .goldGradient
                )
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Level \(gameVM.userProfile.level) Progress")
                        .font(.subheadline).fontWeight(.semibold).foregroundColor(.hjText)
                    Spacer()
                    Text("\(Int(gameVM.userProfile.levelProgress * 100))%")
                        .font(.caption).foregroundColor(.hjPrimaryLight)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.hjSurface2).frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient.primaryGradient)
                            .frame(width: geo.size.width * gameVM.userProfile.levelProgress, height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(gameVM.userProfile.totalPoints) pts").font(.caption).foregroundColor(.hjSubtext)
                    Spacer()
                    Text("\(gameVM.userProfile.pointsToNextLevel) pts to Lv. \(gameVM.userProfile.level + 1)")
                        .font(.caption).foregroundColor(.hjSubtext)
                }
            }
            .padding(16)
            .background(Color.hjSurface)
            .cornerRadius(16)
            .padding(.horizontal, 16)

            Spacer(minLength: 32)
        }
        .padding(.top, 8)
    }
}

private struct PathInfoCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(9)
                .background(gradient)
                .cornerRadius(10)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.hjText)

            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.caption).fontWeight(.semibold).foregroundColor(.hjText)
                Text(subtitle).font(.caption2).foregroundColor(.hjSubtext)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.hjSurface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.hjPrimary.opacity(0.15), lineWidth: 1))
    }
}

// MARK: - Chain Tab

private struct JourneyChainTab: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @EnvironmentObject var gameVM: GameViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let totalDays = 35

    private var dates: [Date] {
        let cal = Calendar.current
        return (0..<totalDays).compactMap { offset in
            cal.date(byAdding: .day, value: -(totalDays - 1 - offset), to: Date())
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            // Header banner
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Don't Break the Chain")
                        .font(.title3).fontWeight(.bold).foregroundColor(.hjText)
                    Text("Show up every day — your chain is your power")
                        .font(.caption).foregroundColor(.hjSubtext)
                }
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill").foregroundColor(.orange).font(.system(size: 20))
                    Text("\(gameVM.userProfile.currentStreak)")
                        .font(.system(size: 28, weight: .bold, design: .rounded)).foregroundColor(.hjText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
            }
            .padding(16)
            .background(Color.hjSurface)
            .cornerRadius(16)

            // Calendar grid
            VStack(spacing: 10) {
                // Weekday labels
                HStack(spacing: 0) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { d in
                        Text(d)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.hjSubtext)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(dates.enumerated()), id: \.offset) { _, date in
                        ChainDayCell(date: date, hasEntry: habitVM.hasAnyEntry(on: date))
                    }
                }
            }
            .padding(16)
            .background(Color.hjSurface)
            .cornerRadius(16)

            // Streak stats
            HStack(spacing: 12) {
                StreakStatCard(value: "\(gameVM.userProfile.currentStreak)", label: "Current Streak", unit: "days", color: .orange)
                StreakStatCard(value: "\(gameVM.userProfile.longestStreak)", label: "Best Streak",    unit: "days", color: .hjGold)
            }

            Spacer(minLength: 32)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

private struct ChainDayCell: View {
    let date: Date
    let hasEntry: Bool

    private var isToday: Bool  { Calendar.current.isDateInToday(date) }
    private var isFuture: Bool { date > Date() }

    private var dayNumber: String {
        let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: date)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    hasEntry
                        ? AnyView(LinearGradient.primaryGradient)
                        : AnyView(isFuture ? Color.hjSurface2.opacity(0.35) : Color.hjSurface2)
                )
                .overlay(Circle().stroke(isToday ? Color.hjGold : Color.clear, lineWidth: 2))
                .shadow(color: hasEntry ? Color.hjPrimary.opacity(0.45) : .clear, radius: 4)

            if hasEntry {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold)).foregroundColor(.white)
            } else {
                Text(dayNumber)
                    .font(.system(size: 10, weight: isFuture ? .light : .medium))
                    .foregroundColor(isFuture ? Color.hjSubtext.opacity(0.35) : .hjSubtext)
            }
        }
        .frame(width: 36, height: 36)
    }
}

private struct StreakStatCard: View {
    let value: String
    let label: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded)).foregroundColor(color)
            Text(unit).font(.caption2).foregroundColor(.hjSubtext)
            Text(label).font(.caption).fontWeight(.medium).foregroundColor(.hjText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color.opacity(0.1))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.25), lineWidth: 1))
    }
}

// MARK: - Partners Tab

private struct JourneyPartnersTab: View {
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var habitVM: HabitViewModel
    @State private var partners: [AccountabilityPartner] = []
    @State private var showAddPartner = false
    @State private var newPartnerName = ""
    @State private var showShareSheet = false
    @State private var shareText = ""

    var body: some View {
        VStack(spacing: 14) {
            // Header card
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Accountability Partners")
                            .font(.title3).fontWeight(.bold).foregroundColor(.hjText)
                        Text("Keep each other on track")
                            .font(.caption).foregroundColor(.hjSubtext)
                    }
                    Spacer()
                    Button {
                        showAddPartner = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(LinearGradient.primaryGradient)
                            .clipShape(Circle())
                            .shadow(color: Color.hjPrimary.opacity(0.4), radius: 6)
                    }
                }

                Button {
                    shareText = buildShareText()
                    showShareSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share My Progress")
                    }
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(LinearGradient.primaryGradient)
                    .cornerRadius(14)
                    .shadow(color: Color.hjPrimary.opacity(0.35), radius: 8)
                }
            }
            .padding(16)
            .background(Color.hjSurface)
            .cornerRadius(16)

            if partners.isEmpty {
                EmptyPartnersView()
            } else {
                ForEach(partners) { partner in
                    PartnerCard(partner: partner) {
                        withAnimation { partners.removeAll { $0.id == partner.id }; savePartners() }
                    } onShare: {
                        shareText = buildShareText()
                        showShareSheet = true
                    }
                }
            }

            Spacer(minLength: 32)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .onAppear { loadPartners() }
        .sheet(isPresented: $showAddPartner) {
            AddPartnerSheet(name: $newPartnerName) { name in
                withAnimation { partners.append(AccountabilityPartner(name: name)) }
                savePartners()
                newPartnerName = ""
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(activityItems: [shareText])
        }
    }

    private func buildShareText() -> String {
        "🔥 My FORGE - Habit Tracker progress:\n• \(gameVM.userProfile.currentStreak)-day streak 🔥\n• Level \(gameVM.userProfile.level) – \(gameVM.userProfile.levelTitle)\n• \(habitVM.habits.count) active habits\n• \(gameVM.userProfile.totalPoints) total points ⭐\n\nBuilding better habits one day at a time! 💪"
    }

    private func loadPartners() {
        guard let data = UserDefaults.standard.data(forKey: "hj_partners_v1"),
              let decoded = try? JSONDecoder().decode([AccountabilityPartner].self, from: data) else { return }
        partners = decoded
    }

    private func savePartners() {
        if let data = try? JSONEncoder().encode(partners) {
            UserDefaults.standard.set(data, forKey: "hj_partners_v1")
        }
    }
}

private struct PartnerCard: View {
    let partner: AccountabilityPartner
    let onDelete: () -> Void
    let onShare: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(LinearGradient.primaryGradient).frame(width: 46, height: 46)
                Text(String(partner.name.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(partner.name).font(.subheadline).fontWeight(.semibold).foregroundColor(.hjText)
                Text("Added \(partner.addedAt.relativeLabel)").font(.caption).foregroundColor(.hjSubtext)
            }

            Spacer()

            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 13)).foregroundColor(.hjPrimary)
                    .padding(9).background(Color.hjPrimary.opacity(0.12)).clipShape(Circle())
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 13)).foregroundColor(.red.opacity(0.75))
                    .padding(9).background(Color.red.opacity(0.1)).clipShape(Circle())
            }
        }
        .padding(14)
        .background(Color.hjSurface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.hjPrimary.opacity(0.12), lineWidth: 1))
    }
}

private struct EmptyPartnersView: View {
    var body: some View {
        VStack(spacing: 14) {
            Text("👥").font(.system(size: 52))
            Text("No partners yet").font(.headline).foregroundColor(.hjText)
            Text("Add accountability partners to share your progress and keep each other motivated on your habit journey.")
                .font(.subheadline).foregroundColor(.hjSubtext).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(Color.hjSurface)
        .cornerRadius(16)
    }
}

private struct AddPartnerSheet: View {
    @Binding var name: String
    let onAdd: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            Color.hjBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                RoundedRectangle(cornerRadius: 3).fill(Color.hjSurface2)
                    .frame(width: 40, height: 5).padding(.top, 16)

                Text("Add Partner")
                    .font(.title2).fontWeight(.bold).foregroundColor(.hjText)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Name").font(.caption).fontWeight(.semibold).foregroundColor(.hjSubtext)
                    TextField("Partner's name", text: $name)
                        .font(.body).foregroundColor(.hjText)
                        .focused($focused)
                        .padding(14)
                        .background(Color.hjSurface)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(focused ? Color.hjPrimary : Color.hjSurface2, lineWidth: 1))
                }
                .padding(.horizontal, 24)

                Button {
                    let t = name.trimmingCharacters(in: .whitespaces)
                    guard !t.isEmpty else { return }
                    onAdd(t); dismiss()
                } label: {
                    Text("Add Partner")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            name.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AnyView(Color.hjSurface2)
                                : AnyView(LinearGradient.primaryGradient)
                        )
                        .cornerRadius(16)
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .onAppear { focused = true }
    }
}

// MARK: - 4 Laws Tab

private struct JourneyLawsTab: View {
    @State private var expandedIndex: Int? = nil

    private let laws: [AtomicLaw] = [
        AtomicLaw(
            number: 1, title: "Make It Obvious", subtitle: "The Cue",
            description: "Design your environment so good habits are visible and easy to trigger. Reduce all friction for desired behaviors.",
            tips: [
                "Place reminders where you will see them every day",
                "Use implementation intentions: 'I will [HABIT] at [TIME] in [LOCATION]'",
                "Build a habit scorecard to identify your current routines",
                "Stack new habits onto existing ones"
            ],
            icon: "eye.fill",
            color: Color(red: 0.30, green: 0.70, blue: 1.00),
            gradientColors: [Color(red: 0.20, green: 0.50, blue: 0.90), Color(red: 0.30, green: 0.72, blue: 1.00)]
        ),
        AtomicLaw(
            number: 2, title: "Make It Attractive", subtitle: "The Craving",
            description: "Use temptation bundling and join communities where your desired behavior is the norm to boost motivation.",
            tips: [
                "Pair an action you want to do with one you need to do",
                "Join a group where your desired behavior is normal",
                "Create a motivation ritual before difficult habits",
                "Reframe habits as opportunities, not obligations"
            ],
            icon: "heart.fill",
            color: Color(red: 1.00, green: 0.40, blue: 0.60),
            gradientColors: [Color(red: 0.85, green: 0.20, blue: 0.50), Color(red: 1.00, green: 0.50, blue: 0.70)]
        ),
        AtomicLaw(
            number: 3, title: "Make It Easy", subtitle: "The Response",
            description: "Reduce friction to two minutes or less. The goal is simply to show up, not to be perfect every single day.",
            tips: [
                "Use the 2-minute rule: scale any habit down to 2 minutes",
                "Remove steps between you and your habit",
                "Prepare your environment the night before",
                "Automate as many healthy behaviors as possible"
            ],
            icon: "bolt.fill",
            color: Color(red: 1.00, green: 0.75, blue: 0.20),
            gradientColors: [Color(red: 0.90, green: 0.60, blue: 0.10), Color(red: 1.00, green: 0.80, blue: 0.30)]
        ),
        AtomicLaw(
            number: 4, title: "Make It Satisfying", subtitle: "The Reward",
            description: "Use immediate rewards to reinforce habits. Track your chain and never miss twice in a row.",
            tips: [
                "Use a habit tracker to build a visual streak",
                "Give yourself an immediate reward after completing a habit",
                "Never miss two days in a row",
                "The chain itself becomes the reward — protect it"
            ],
            icon: "star.fill",
            color: Color(red: 0.35, green: 0.88, blue: 0.50),
            gradientColors: [Color(red: 0.20, green: 0.72, blue: 0.38), Color(red: 0.40, green: 0.90, blue: 0.58)]
        )
    ]

    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("The 4 Laws of Behavior Change")
                    .font(.title3).fontWeight(.bold).foregroundColor(.hjText)
                Text("Based on James Clear's Atomic Habits — tap each law to expand")
                    .font(.caption).foregroundColor(.hjSubtext)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.hjSurface)
            .cornerRadius(16)

            ForEach(Array(laws.enumerated()), id: \.offset) { idx, law in
                LawCard(law: law, isExpanded: expandedIndex == idx) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        expandedIndex = expandedIndex == idx ? nil : idx
                    }
                }
            }

            Spacer(minLength: 32)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

private struct AtomicLaw {
    let number: Int
    let title: String
    let subtitle: String
    let description: String
    let tips: [String]
    let icon: String
    let color: Color
    let gradientColors: [Color]

    var gradient: LinearGradient {
        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private struct LawCard: View {
    let law: AtomicLaw
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .fill(law.gradient)
                            .frame(width: 52, height: 52)
                            .shadow(color: law.color.opacity(0.4), radius: 6)
                        VStack(spacing: 2) {
                            Text("Law \(law.number)")
                                .font(.system(size: 8, weight: .bold)).foregroundColor(.white.opacity(0.85))
                            Image(systemName: law.icon)
                                .font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(law.title)
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.hjText)
                        Text(law.subtitle)
                            .font(.caption).fontWeight(.semibold).foregroundColor(law.color)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(.hjSubtext)
                        .padding(7).background(Color.hjSurface2).clipShape(Circle())
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Rectangle().fill(Color.hjSurface2).frame(height: 1).padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text(law.description)
                        .font(.subheadline).foregroundColor(.hjSubtext)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Practice Tips")
                            .font(.caption).fontWeight(.bold).foregroundColor(law.color)

                        ForEach(law.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 10) {
                                Circle().fill(law.color).frame(width: 6, height: 6).padding(.top, 5)
                                Text(tip)
                                    .font(.caption).foregroundColor(.hjSubtext)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .background(Color.hjSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isExpanded ? law.color.opacity(0.4) : Color.hjPrimary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: isExpanded ? law.color.opacity(0.12) : .clear, radius: 8)
    }
}
