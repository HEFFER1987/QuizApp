import SwiftUI

struct ScoreProgressRing: View {
    let progress: Double
    let percentText: String
    let caption: String
    var ringColor: Color = QuizTheme.publishedGlow
    var lineWidth: CGFloat = 8
    var size: CGFloat = 86

    var body: some View {
        ZStack {
            Circle()
                .stroke(ringColor.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: ringColor.opacity(0.65), radius: 8, x: 0, y: 0)

            VStack(spacing: 2) {
                Text(percentText)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(caption)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 8)
        }
        .frame(width: size, height: size)
    }
}
