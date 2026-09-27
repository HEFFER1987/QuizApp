import SwiftUI

struct QuizBuilderStepHeader: View {
    let currentStep: QuizBuilderStep

    private let circleSize: CGFloat = 32

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                connectorRow
                circlesRow
            }
            titlesRow
        }
    }

    private var connectorRow: some View {
        GeometryReader { geometry in
            let steps = QuizBuilderStep.allCases
            let slotWidth = geometry.size.width / CGFloat(steps.count)
            let lineY = circleSize / 2

            ForEach(0..<(steps.count - 1), id: \.self) { index in
                let step = steps[index]
                let startX = slotWidth * (CGFloat(index) + 0.5) + circleSize / 2 + 4
                let endX = slotWidth * (CGFloat(index) + 1.5) - circleSize / 2 - 4
                let width = max(endX - startX, 0)

                Rectangle()
                    .fill(connectorColor(for: step).opacity(0.55))
                    .frame(width: width, height: 1.5)
                    .position(x: startX + width / 2, y: lineY)
            }
        }
        .frame(height: circleSize)
    }

    private var circlesRow: some View {
        HStack(spacing: 0) {
            ForEach(QuizBuilderStep.allCases, id: \.self) { step in
                circle(for: step)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var titlesRow: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(QuizBuilderStep.allCases, id: \.self) { step in
                stepTitle(
                    step.title,
                    weight: step == currentStep ? .semibold : .regular,
                    color: step == currentStep ? QuizTheme.draftGlow : QuizTheme.mutedText
                )
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func circle(for step: QuizBuilderStep) -> some View {
        let isActive = step == currentStep
        let isPast = step.rawValue < currentStep.rawValue
        let accent = accentColor(isActive: isActive, isPast: isPast)

        return ZStack {
            Circle()
                .fill(accent.opacity(isActive || isPast ? 0.22 : 0.12))
                .frame(width: circleSize, height: circleSize)
            Circle()
                .stroke(accent, lineWidth: isActive ? 2 : 1.2)
                .frame(width: circleSize, height: circleSize)
            Text("\(step.number)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(accent)
        }
        .shadow(color: isActive ? accent.opacity(0.55) : .clear, radius: 8, x: 0, y: 0)
    }

    private func stepTitle(
        _ title: String,
        weight: Font.Weight,
        color: Color
    ) -> some View {
        let words = title.split(separator: " ").map(String.init)

        return VStack(spacing: 1) {
            ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                Text(word)
                    .font(.system(size: 12, weight: weight, design: .rounded))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func connectorColor(for step: QuizBuilderStep) -> Color {
        step.rawValue < currentStep.rawValue
            ? QuizTheme.draftGlow
            : QuizTheme.publishedGlow
    }

    private func accentColor(isActive: Bool, isPast: Bool) -> Color {
        if isActive || isPast {
            return QuizTheme.draftGlow
        }
        return QuizTheme.publishedGlow.opacity(0.85)
    }
}

extension QuizBuilderStep {
    var title: String {
        switch self {
        case .quizDetails: return Strings.QuizBuilder.Step.quizDetails
        case .questions: return Strings.QuizBuilder.Step.questions
        case .preview: return Strings.QuizBuilder.Step.preview
        case .publish: return Strings.QuizBuilder.Step.publish
        }
    }
}
