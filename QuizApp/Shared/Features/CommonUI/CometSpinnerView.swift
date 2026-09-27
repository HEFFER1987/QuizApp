import SwiftUI

/// A "comet trail" activity indicator: a conic-gradient ring whose bright
/// head fades into a long trailing tail, with a small glowing dot locked to
/// the leading edge of the arc. Both pieces rotate together continuously.
///
/// Sizes itself from the layout proposal: apply `.frame(width:height:)` for an
/// explicit footprint (backdrop includes the fade band). Unbounded or very large
/// proposals fall back to a compact default.
struct CometSpinnerView: View {
    var lineWidth: CGFloat? = nil
    var trailingGlow: Color = QuizTheme.draftGlow
    var leadingGlow: Color = QuizTheme.publishedGlow
    var duration: Double = 1.0

    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let defaultSpinnerDiameter: CGFloat = 64
    private static let backdropFadeFraction: CGFloat = 0.4

    private static func backdropScale() -> CGFloat {
        1 + 2 * backdropFadeFraction
    }

    private static var defaultBackdropDiameter: CGFloat {
        defaultSpinnerDiameter * backdropScale()
    }

    private func resolvedLineWidth(for spinnerSize: CGFloat) -> CGFloat {
        lineWidth ?? max(spinnerSize / 8, 4)
    }

    private func backdropFadeBand(for spinnerSize: CGFloat) -> CGFloat {
        spinnerSize * Self.backdropFadeFraction
    }

    private func backdropSolidRadius(for spinnerSize: CGFloat) -> CGFloat {
        spinnerSize / 2
    }

    private func backdropFadeEndRadius(for spinnerSize: CGFloat) -> CGFloat {
        backdropSolidRadius(for: spinnerSize) + backdropFadeBand(for: spinnerSize)
    }

    private func backdropDiameter(for spinnerSize: CGFloat) -> CGFloat {
        backdropFadeEndRadius(for: spinnerSize) * 2
    }

    /// Interprets the overlay geometry as the full backdrop bounds.
    private func spinnerDiameter(forContainerSize proposed: CGSize) -> CGFloat {
        let width = proposed.width
        let height = proposed.height
        guard width > 0, height > 0, width.isFinite, height.isFinite else {
            return Self.defaultSpinnerDiameter
        }

        let backdropSide = min(width, height)
        let largeLayoutThreshold = Self.defaultBackdropDiameter * 2

        // Full-screen loaders pass very large width and height; keep the compact default.
        if width > largeLayoutThreshold, height > largeLayoutThreshold {
            return Self.defaultSpinnerDiameter
        }

        return backdropSide / Self.backdropScale()
    }

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .frame(
                minWidth: Self.defaultBackdropDiameter,
                minHeight: Self.defaultBackdropDiameter
            )
            .overlay {
                GeometryReader { geometry in
                    let spinnerSize = spinnerDiameter(forContainerSize: geometry.size)
                    let resolvedLine = resolvedLineWidth(for: spinnerSize)
                    let solidRadius = backdropSolidRadius(for: spinnerSize)
                    let fadeEndRadius = backdropFadeEndRadius(for: spinnerSize)
                    let backdropSide = backdropDiameter(for: spinnerSize)

                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: backdropSide, height: backdropSide)
                            .mask(
                                RadialGradient(
                                    colors: [.black, .clear],
                                    center: .center,
                                    startRadius: solidRadius,
                                    endRadius: fadeEndRadius
                                )
                            )

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
                                    style: StrokeStyle(lineWidth: resolvedLine, lineCap: .round)
                                )
                                .shadow(color: trailingGlow.opacity(0.5), radius: 4)
                                .shadow(color: trailingGlow, radius: 5)

                            Circle()
                                .fill(trailingGlow)
                                .frame(width: resolvedLine, height: resolvedLine)
                                .shadow(color: trailingGlow, radius: 5)
                                .shadow(color: trailingGlow.opacity(0.5), radius: 4)
                                .offset(x: spinnerSize / 2)

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
                                    style: StrokeStyle(lineWidth: resolvedLine, lineCap: .round)
                                )
                                .shadow(color: leadingGlow.opacity(0.5), radius: 4)
                                .shadow(color: leadingGlow, radius: 5)

                            Circle()
                                .fill(leadingGlow)
                                .frame(width: resolvedLine, height: resolvedLine)
                                .shadow(color: leadingGlow, radius: 5)
                                .shadow(color: leadingGlow.opacity(0.5), radius: 4)
                                .offset(x: -spinnerSize / 2)
                        }
                        .frame(width: spinnerSize, height: spinnerSize)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    }
                    .frame(width: backdropSide, height: backdropSide)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
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
        Color.white
        VStack(spacing: 32) {
            CometSpinnerView()
            CometSpinnerView()
                .frame(width: 134, height: 134)
        }
    }
    .ignoresSafeArea()
}
