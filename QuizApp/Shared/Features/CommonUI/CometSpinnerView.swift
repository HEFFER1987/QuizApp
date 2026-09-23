import SwiftUI

/// A "comet trail" activity indicator: a conic-gradient ring whose bright
/// head fades into a long trailing tail, with a small glowing dot locked to
/// the leading edge of the arc. Both pieces rotate together continuously.
struct CometSpinnerView: View {
    var size: CGFloat = 64
    var lineWidth: CGFloat? = nil
    var trailingGlow: Color = QuizTheme.draftGlow
    var leadingGlow: Color = QuizTheme.publishedGlow
    var duration: Double = 1.0

    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var resolvedLineWidth: CGFloat {
        lineWidth ?? max(size / 8, 4)
    }

    private var tipDiameter: CGFloat {
        resolvedLineWidth * 0.8
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    AngularGradient(
                        stops: [
                            .init(color: trailingGlow.opacity(0), location: 0.0),
                            .init(color: trailingGlow.opacity(0), location: 0.5),
                            .init(color: trailingGlow.opacity(0), location: 0.6),
                            .init(color: trailingGlow.opacity(0.15), location: 0.7),
                            .init(color: trailingGlow, location: 1.0)
                        ],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: resolvedLineWidth, lineCap: .round)
                )
                .shadow(color: trailingGlow.opacity(0.5), radius: 4)
                .shadow(color: trailingGlow, radius: 5)

            Circle()
                .fill(trailingGlow)
                .frame(width: resolvedLineWidth, height: resolvedLineWidth)
                .shadow(color: trailingGlow, radius: 5)
                .shadow(color: trailingGlow.opacity(0.5), radius: 4)
                .offset(x: size / 2)
            
            Circle()
                .stroke(
                    AngularGradient(
                        stops: [
                            .init(color: leadingGlow.opacity(0), location: 0.0),
                            .init(color: leadingGlow.opacity(0), location: 0.1),
                            .init(color: leadingGlow.opacity(0.15), location: 0.2),
                            .init(color: leadingGlow, location: 0.5),
                            .init(color: leadingGlow.opacity(0), location: 0.5),
                            .init(color: leadingGlow.opacity(0), location: 1.0)
                        ],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: resolvedLineWidth, lineCap: .round)
                )
                .shadow(color: leadingGlow.opacity(0.5), radius: 4)
                .shadow(color: leadingGlow, radius: 5)
            
            Circle()
                .fill(leadingGlow)
                .frame(width: resolvedLineWidth, height: resolvedLineWidth)
                .shadow(color: leadingGlow, radius: 5)
                .shadow(color: leadingGlow.opacity(0.5), radius: 4)
                .offset(x: -size / 2)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(isAnimating ? 360 : 0))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        CometSpinnerView()
    }
    .ignoresSafeArea()
}
