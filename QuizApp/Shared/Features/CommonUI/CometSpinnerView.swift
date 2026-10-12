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

    private func rotationDegrees(for date: Date) -> Double {
        let cycles = date.timeIntervalSinceReferenceDate / duration
        return cycles.truncatingRemainder(dividingBy: 1) * 360
    }

    @ViewBuilder
    private func cometRings(
        spinnerSize: CGFloat,
        resolvedLine: CGFloat
    ) -> some View {
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
                .cometSpinnerGlow(trailingGlow)

            Circle()
                .fill(trailingGlow)
                .frame(width: resolvedLine, height: resolvedLine)
                .cometSpinnerGlow(trailingGlow)
                .offset(x: spinnerSize / 2)

            Circle()
                .stroke(
                    AngularGradient(
                        stops: [
                            .init(color: leadingGlow.opacity(0), location: 0.0),
                            .init(color: leadingGlow.opacity(0.1), location: 0.1),
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
                .cometSpinnerGlow(leadingGlow)

            Circle()
                .fill(leadingGlow)
                .frame(width: resolvedLine, height: resolvedLine)
                .cometSpinnerGlow(leadingGlow)
                .offset(x: -spinnerSize / 2)
        }
        .frame(width: spinnerSize, height: spinnerSize)
    }

    @ViewBuilder
    private func spinnerStack(
        spinnerSize: CGFloat,
        resolvedLine: CGFloat,
        solidRadius: CGFloat,
        fadeEndRadius: CGFloat,
        backdropSide: CGFloat,
        rotationDegrees: Double
    ) -> some View {
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

            cometRings(spinnerSize: spinnerSize, resolvedLine: resolvedLine)
                .rotationEffect(.degrees(rotationDegrees))
        }
        .frame(width: backdropSide, height: backdropSide)
    }

    var body: some View {
        GeometryReader { geometry in
            let spinnerSize = spinnerDiameter(forContainerSize: geometry.size)
            let resolvedLine = resolvedLineWidth(for: spinnerSize)
            let solidRadius = backdropSolidRadius(for: spinnerSize)
            let fadeEndRadius = backdropFadeEndRadius(for: spinnerSize)
            let backdropSide = backdropDiameter(for: spinnerSize)

            Group {
                #if os(macOS)
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

                    CometSpinnerMacRotor(
                        duration: duration,
                        reduceMotion: reduceMotion,
                        spinnerSize: spinnerSize,
                        resolvedLine: resolvedLine,
                        trailingGlow: trailingGlow,
                        leadingGlow: leadingGlow
                    )
                    .frame(width: spinnerSize, height: spinnerSize)
                }
                .frame(width: backdropSide, height: backdropSide)
                #else
                TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduceMotion)) { context in
                    spinnerStack(
                        spinnerSize: spinnerSize,
                        resolvedLine: resolvedLine,
                        solidRadius: solidRadius,
                        fadeEndRadius: fadeEndRadius,
                        backdropSide: backdropSide,
                        rotationDegrees: rotationDegrees(for: context.date)
                    )
                }
                #endif
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(
            minWidth: Self.defaultBackdropDiameter,
            minHeight: Self.defaultBackdropDiameter
        )
    }
}

#if os(macOS)
import AppKit

private struct CometSpinnerMacRotorContent: View {
    let spinnerSize: CGFloat
    let resolvedLine: CGFloat
    let trailingGlow: Color
    let leadingGlow: Color

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
                    style: StrokeStyle(lineWidth: resolvedLine, lineCap: .round)
                )

            Circle()
                .fill(trailingGlow)
                .frame(width: resolvedLine, height: resolvedLine)
                .offset(x: spinnerSize / 2)

            Circle()
                .stroke(
                    AngularGradient(
                        stops: [
                            .init(color: leadingGlow.opacity(0), location: 0.0),
                            .init(color: leadingGlow.opacity(0.1), location: 0.1),
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

            Circle()
                .fill(leadingGlow)
                .frame(width: resolvedLine, height: resolvedLine)
                .offset(x: -spinnerSize / 2)
        }
        .frame(width: spinnerSize, height: spinnerSize)
    }
}

private final class CometRotorContainerView: NSView {
    private let hostingView: NSHostingView<CometSpinnerMacRotorContent>
    var duration: Double
    private var shouldSpin = true
    private var didAttachLayerAnimation = false

    init(content: CometSpinnerMacRotorContent, spinnerSize: CGFloat, duration: Double) {
        self.duration = duration
        hostingView = NSHostingView(rootView: content)
        super.init(frame: NSRect(x: 0, y: 0, width: spinnerSize, height: spinnerSize))
        hostingView.frame = bounds
        hostingView.autoresizingMask = [.width, .height]
        addSubview(hostingView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateContent(_ content: CometSpinnerMacRotorContent) {
        hostingView.rootView = content
    }

    func setSpinning(enabled: Bool) {
        shouldSpin = enabled
        if !enabled {
            hostingView.layer?.removeAnimation(forKey: "cometSpin")
            didAttachLayerAnimation = false
            return
        }
        attachLayerAnimationIfNeeded()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        attachLayerAnimationIfNeeded()
    }

    override func layout() {
        super.layout()
        hostingView.frame = bounds
        guard let layer = hostingView.layer else { return }
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    private func attachLayerAnimationIfNeeded() {
        guard shouldSpin, window != nil, !didAttachLayerAnimation else { return }
        hostingView.wantsLayer = true
        guard let layer = hostingView.layer else { return }

        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = -2 * Double.pi
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "cometSpin")

        didAttachLayerAnimation = true
    }
}

/// AppKit layer animation — does not depend on SwiftUI body refresh per frame.
private struct CometSpinnerMacRotor: NSViewRepresentable {
    let duration: Double
    let reduceMotion: Bool
    let spinnerSize: CGFloat
    let resolvedLine: CGFloat
    let trailingGlow: Color
    let leadingGlow: Color

    func makeNSView(context: Context) -> CometRotorContainerView {
        let view = CometRotorContainerView(
            content: rotorContent,
            spinnerSize: spinnerSize,
            duration: duration
        )
        view.setSpinning(enabled: !reduceMotion)
        return view
    }

    func updateNSView(_ nsView: CometRotorContainerView, context: Context) {
        nsView.duration = duration
        nsView.updateContent(rotorContent)
        nsView.setSpinning(enabled: !reduceMotion)
    }

    private var rotorContent: CometSpinnerMacRotorContent {
        CometSpinnerMacRotorContent(
            spinnerSize: spinnerSize,
            resolvedLine: resolvedLine,
            trailingGlow: trailingGlow,
            leadingGlow: leadingGlow
        )
    }
}
#endif

private extension View {
    @ViewBuilder
    func cometSpinnerGlow(_ color: Color) -> some View {
        shadow(color: color.opacity(0.5), radius: 4)
            .shadow(color: color, radius: 5)
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
