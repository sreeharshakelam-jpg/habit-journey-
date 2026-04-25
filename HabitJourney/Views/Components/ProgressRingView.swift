import SwiftUI

struct ProgressRingView: View {
    var progress: Double        // 0.0 – 1.0
    var size: CGFloat = 56
    var lineWidth: CGFloat = 6
    var color: Color = .hjPrimary
    var showPercentage: Bool = true

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: animatedProgress)

            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .foregroundColor(.hjText)
            }
        }
        .frame(width: size, height: size)
        .onAppear { animatedProgress = progress }
        .onChange(of: progress) { animatedProgress = $0 }
    }
}

struct MiniProgressBar: View {
    var progress: Double
    var color: Color = .hjPrimary
    var height: CGFloat = 6

    @State private var animated: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color.opacity(0.15))

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geo.size.width * animated)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: animated)
            }
        }
        .frame(height: height)
        .onAppear { animated = progress }
        .onChange(of: progress) { animated = $0 }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressRingView(progress: 0.75, size: 80)
        MiniProgressBar(progress: 0.6, color: .hjGreen)
            .frame(height: 8)
            .padding(.horizontal)
    }
    .padding()
    .background(Color.hjBackground)
}
