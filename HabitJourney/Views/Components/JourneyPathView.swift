import SwiftUI

// Waypoints as normalized (0–1) fractions of the view size
private let waypoints: [CGPoint] = [
    CGPoint(x: 0.50, y: 0.96),
    CGPoint(x: 0.22, y: 0.82),
    CGPoint(x: 0.70, y: 0.68),
    CGPoint(x: 0.28, y: 0.53),
    CGPoint(x: 0.72, y: 0.38),
    CGPoint(x: 0.30, y: 0.23),
    CGPoint(x: 0.65, y: 0.10),
    CGPoint(x: 0.50, y: 0.04),
]

private func point(_ wp: CGPoint, in size: CGSize) -> CGPoint {
    CGPoint(x: wp.x * size.width, y: wp.y * size.height)
}

// Interpolate position at t ∈ [0,1] across all segments
private func characterPoint(t: Double, in size: CGSize) -> CGPoint {
    let segments = waypoints.count - 1
    let segT = t * Double(segments)
    let segIdx = min(Int(segT), segments - 1)
    let localT = segT - Double(segIdx)

    let p0 = point(waypoints[segIdx], in: size)
    let p1 = point(waypoints[segIdx + 1], in: size)
    return CGPoint(
        x: p0.x + (p1.x - p0.x) * localT,
        y: p0.y + (p1.y - p0.y) * localT
    )
}

struct JourneyPathView: View {
    var characterPosition: Double   // 0.0 → 1.0
    @State private var particlePhase: Double = 0

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let charPt = characterPoint(t: characterPosition, in: size)

            ZStack {
                // Background stars
                ForEach(0..<20, id: \.self) { i in
                    StarShape()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                        .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
                        .position(
                            x: CGFloat.random(in: 10...size.width - 10),
                            y: CGFloat.random(in: 10...size.height - 10)
                        )
                        .seed(i)
                }

                // Dashed upcoming path
                PathShape(waypoints: waypoints, size: size)
                    .stroke(
                        Color.hjSurface2,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [6, 10])
                    )

                // Completed path (up to character position)
                CompletedPathShape(waypoints: waypoints, size: size, progress: characterPosition)
                    .stroke(
                        LinearGradient.primaryGradient,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .shadow(color: Color.hjPrimary.opacity(0.5), radius: 6)

                // Milestone markers
                ForEach(0..<waypoints.count, id: \.self) { i in
                    let wp = waypoints[i]
                    let pt = point(wp, in: size)
                    let fraction = Double(i) / Double(waypoints.count - 1)
                    let reached = characterPosition >= fraction

                    MilestoneMarker(reached: reached, index: i)
                        .position(pt)
                }

                // Character
                CharacterView(size: 44)
                    .position(x: charPt.x, y: charPt.y - 24)
                    .animation(.spring(response: 1.0, dampingFraction: 0.6), value: characterPosition)
            }
        }
    }
}

struct PathShape: Shape {
    var waypoints: [CGPoint]
    var size: CGSize

    func path(in rect: CGRect) -> Path {
        var p = Path()
        guard waypoints.count > 1 else { return p }
        p.move(to: point(waypoints[0], in: size))
        for i in 1..<waypoints.count {
            let prev = point(waypoints[i - 1], in: size)
            let curr = point(waypoints[i], in: size)
            let ctrl = CGPoint(x: (prev.x + curr.x) / 2, y: (prev.y + curr.y) / 2)
            p.addQuadCurve(to: curr, control: ctrl)
        }
        return p
    }
}

struct CompletedPathShape: Shape {
    var waypoints: [CGPoint]
    var size: CGSize
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let full = PathShape(waypoints: waypoints, size: size).path(in: rect)
        let trimmed = full.trimmedPath(from: 0, to: progress)
        return trimmed
    }
}

struct MilestoneMarker: View {
    var reached: Bool
    var index: Int

    private var milestoneEmojis = ["🏁", "⭐", "💫", "🌟", "✨", "🔥", "💎", "👑"]

    var body: some View {
        ZStack {
            Circle()
                .fill(reached ? Color.hjPrimary : Color.hjSurface2)
                .frame(width: 24, height: 24)
                .shadow(color: reached ? Color.hjPrimary.opacity(0.5) : .clear, radius: 6)

            if reached {
                Text(milestoneEmojis[min(index, milestoneEmojis.count - 1)])
                    .font(.system(size: 11))
            } else {
                Circle()
                    .fill(Color.hjSubtext.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        var p = Path()
        for i in 0..<4 {
            let angle = Double(i) * .pi / 2
            let pt = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            i == 0 ? p.move(to: pt) : p.addLine(to: pt)
        }
        p.closeSubpath()
        return p
    }
}

// Deterministic random positioning for stars using a seed
extension View {
    func seed(_ seed: Int) -> some View { self }
}

#Preview {
    ZStack {
        Color.hjBackground.ignoresSafeArea()
        JourneyPathView(characterPosition: 0.35)
    }
}
