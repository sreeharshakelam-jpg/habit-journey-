import SwiftUI

struct AchievementBannerView: View {
    let achievement: Achievement
    @State private var scale: CGFloat = 0.8

    var body: some View {
        HStack(spacing: 14) {
            Text(achievement.type.emoji)
                .font(.system(size: 36))
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        scale = 1.0
                    }
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.hjGold)
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text(achievement.type.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.hjText)

                Text("+\(achievement.type.pointValue) pts")
                    .font(.caption)
                    .foregroundColor(.hjGold)
            }

            Spacer()

            Image(systemName: "sparkles")
                .foregroundColor(.hjGold)
                .font(.title2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.hjSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.hjGold.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.hjGold.opacity(0.2), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
    }
}

struct AchievementBadgeView: View {
    let achievement: Achievement
    var locked: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(locked ? Color.hjSurface2 : Color.hjSurface)
                    .frame(width: 56, height: 56)

                if !locked {
                    Circle()
                        .stroke(Color.hjGold.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 56, height: 56)
                }

                Text(locked ? "🔒" : achievement.type.emoji)
                    .font(.system(size: 26))
                    .opacity(locked ? 0.4 : 1)
            }

            Text(achievement.type.title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(locked ? .hjSubtext : .hjText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 60)
        }
    }
}
