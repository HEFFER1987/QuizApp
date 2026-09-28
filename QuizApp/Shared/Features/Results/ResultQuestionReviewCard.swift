import SwiftUI

struct ResultQuestionReviewCard: View {
    let question: ResultQuestionReview
    let isExplanationExpanded: Bool
    let showsTimelineConnector: Bool
    let onToggleExplanation: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            timelineColumn
            cardContent
        }
    }

    private var timelineColumn: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(QuizTheme.publishedGlow.opacity(0.18))
                    .frame(width: 28, height: 28)

                Circle()
                    .stroke(QuizTheme.publishedGlow, lineWidth: 1.5)
                    .frame(width: 28, height: 28)
                    .shadow(color: QuizTheme.publishedGlow.opacity(0.45), radius: 6)

                Text("\(question.number)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            if showsTimelineConnector {
                Rectangle()
                    .fill(QuizTheme.publishedGlow.opacity(0.35))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .padding(.top, 4)
            }
        }
        .frame(width: 28)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow

            if let codeSnippet = question.codeSnippet, !codeSnippet.isEmpty {
                QuizCodeSnippetView(code: codeSnippet, showsCopyButton: false)
            }

            if let options = question.options, !options.isEmpty {
                optionsList(options)
            } else {
                answerComparison
            }

            if !question.explanation.isEmpty {
                explanationSection
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(question.prompt)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: question.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(question.isCorrect ? QuizTheme.excellentGlow : QuizTheme.draftGlow)
                .shadow(
                    color: (question.isCorrect ? QuizTheme.excellentGlow : QuizTheme.draftGlow).opacity(0.5),
                    radius: 5
                )
        }
    }

    private var answerComparison: some View {
        HStack(alignment: .top, spacing: 10) {
            answerBox(
                title: Strings.ResultsDetail.yourAnswer,
                value: question.userAnswer,
                accent: question.isCorrect ? QuizTheme.excellentGlow : QuizTheme.draftGlow,
                icon: question.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
            )

            answerBox(
                title: Strings.ResultsDetail.correctAnswer,
                value: question.correctAnswer,
                accent: QuizTheme.excellentGlow,
                icon: "checkmark.circle.fill"
            )
        }
    }

    private func answerBox(
        title: String,
        value: String,
        accent: Color,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)

            HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accent)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(accent.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(accent.opacity(0.85), lineWidth: 1.2)
        )
        .shadow(color: accent.opacity(0.2), radius: 6, x: 0, y: 0)
    }

    private func optionsList(_ options: [ResultAnswerOption]) -> some View {
        VStack(spacing: 8) {
            ForEach(options) { option in
                optionRow(option)
            }
        }
    }

    private func optionRow(_ option: ResultAnswerOption) -> some View {
        let accent = accentColor(for: option.state)

        return HStack(spacing: 10) {
            Text(option.text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let icon = iconName(for: option.state) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accent)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(accent.opacity(option.state == .neutral ? 0.04 : 0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    option.state == .neutral ? Color.white.opacity(0.1) : accent.opacity(0.85),
                    lineWidth: 1.2
                )
        )
    }

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onToggleExplanation) {
                HStack {
                    Text(Strings.ResultsDetail.explanation)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(QuizTheme.mutedText)

                    Spacer()

                    Image(systemName: isExplanationExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(QuizTheme.mutedText)
                }
            }
            .buttonStyle(.plain)

            if isExplanationExpanded {
                Text(question.explanation)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.86))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func accentColor(for state: ResultAnswerOptionState) -> Color {
        switch state {
        case .neutral:
            return QuizTheme.mutedText
        case .userCorrect, .correctOnly:
            return QuizTheme.excellentGlow
        case .userWrong:
            return QuizTheme.draftGlow
        }
    }

    private func iconName(for state: ResultAnswerOptionState) -> String? {
        switch state {
        case .neutral:
            return nil
        case .userCorrect, .correctOnly:
            return "checkmark.circle.fill"
        case .userWrong:
            return "xmark.circle.fill"
        }
    }
}
