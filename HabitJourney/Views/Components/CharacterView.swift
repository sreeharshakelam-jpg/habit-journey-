import SwiftUI

struct CharacterView: View {
    var size: CGFloat = 48
    var isAnimating: Bool = false
    @State private var bounce: Bool = false
    @State private var eyeBlink: Bool = false

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(Color.hjPrimary.opacity(0.3))
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: size * 0.2)

            // Shadow
            Ellipse()
                .fill(Color.black.opacity(0.3))
                .frame(width: size * 0.8, height: size * 0.2)
                .offset(y: size * 0.7)
                .blur(radius: 4)

            // Body
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(LinearGradient.primaryGradient)
                .frame(width: size * 0.55, height: size * 0.55)
                .offset(y: size * 0.25)

            // Head
            Circle()
                .fill(LinearGradient(
                    colors: [Color(red: 0.55, green: 0.47, blue: 1.0), Color.hjPrimary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: size * 0.7, height: size * 0.7)
                .offset(y: -size * 0.06)

            // Eyes
            HStack(spacing: size * 0.14) {
                EyeShape(size: size * 0.11, isBlinking: eyeBlink)
                EyeShape(size: size * 0.11, isBlinking: eyeBlink)
            }
            .offset(y: -size * 0.12)

            // Smile
            SmileShape(size: size * 0.25)
                .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: size * 0.04, lineCap: .round))
                .frame(width: size * 0.25, height: size * 0.12)
                .offset(y: size * 0.04)

            // Star badge
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.20))
                .foregroundColor(.hjGold)
                .offset(x: size * 0.30, y: -size * 0.28)
                .shadow(color: Color.hjGold.opacity(0.6), radius: 4)
        }
        .frame(width: size * 1.4, height: size * 1.6)
        .offset(y: bounce ? -4 : 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                bounce = true
            }
            Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.12)) { eyeBlink = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.12)) { eyeBlink = false }
                }
            }
        }
    }
}

struct EyeShape: View {
    var size: CGFloat
    var isBlinking: Bool

    var body: some View {
        Capsule()
            .fill(Color.white)
            .frame(width: size, height: isBlinking ? size * 0.15 : size)
            .overlay(
                Circle()
                    .fill(Color(red: 0.15, green: 0.10, blue: 0.30))
                    .frame(width: size * 0.55, height: size * 0.55)
                    .opacity(isBlinking ? 0 : 1)
            )
    }
}

struct SmileShape: Shape {
    var size: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addQuadCurve(
            to: CGPoint(x: rect.width, y: 0),
            control: CGPoint(x: rect.width / 2, y: rect.height)
        )
        return p
    }
}

#Preview {
    ZStack {
        Color.hjBackground.ignoresSafeArea()
        CharacterView(size: 64)
    }
}
