import SwiftUI

struct QuizBuilderPreviewInfoCard: View {
    let title: String
    let descriptionText: String
    let cover: QuizCoverOption
    let questionCount: Int
    let estimatedMinutes: Int

    private var accent: Color {
        cover.usesOrangeAccent ? QuizTheme.draftGlow : QuizTheme.publishedGlow
    }

    private var trimmedDescription: String {
        descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            coverIcon
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                if !trimmedDescription.isEmpty {
                    Text(trimmedDescription)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(QuizTheme.mutedText)
                }

                HStack(spacing: 14) {
                    metaLabel(
                        icon: "questionmark.circle",
                        text: Strings.QuizBuilder.Preview.questionsCount(questionCount)
                    )
                    metaLabel(
                        icon: "clock",
                        text: Strings.QuizBuilder.Preview.estimatedMinutes(estimatedMinutes)
                    )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(QuizPlayCardBackground())
    }

    private var coverIcon: some View {
        ZStack {
            Circle()
                .stroke(accent.opacity(0.35), lineWidth: 1)
                .frame(width: 64, height: 64)
            Circle()
                .stroke(accent.opacity(0.55), lineWidth: 1.2)
                .frame(width: 52, height: 52)
            Circle()
                .fill(accent.opacity(0.18))
                .frame(width: 44, height: 44)
            Image(systemName: cover.systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(accent)
                .shadow(color: accent.opacity(0.5), radius: 4, x: 0, y: 0)
        }
    }

    private func metaLabel(icon: String, text: String) -> some View {
        Label {
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        } icon: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(accent)
        }
        .labelStyle(.titleAndIcon)
    }
}

struct QuizBuilderPreviewQuestionCard: View {
    let question: QuizBuilderQuestion
    let currentIndex: Int
    let total: Int
    let isBookmarked: Bool
    let isOptionSelected: (UUID) -> Bool
    let onSelectOption: (UUID) -> Void
    let onToggleBookmark: () -> Void

    private var filledOptions: [QuizBuilderAnswerOption] {
        question.options.filter {
            !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            progressHeader
            Text(question.prompt)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            optionsList
            bookmarkButton
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(QuizPlayCardBackground())
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.QuizBuilder.Preview.questionProgress(currentIndex + 1, max(total, 1)))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.publishedGlow.opacity(0.9))

            QuizPlayProgressHeader(
                currentIndex: currentIndex,
                total: total,
                accent: QuizTheme.draftGlow,
                showsNumericLabel: false
            )
        }
    }

    private var optionsList: some View {
        VStack(spacing: 10) {
            ForEach(Array(filledOptions.enumerated()), id: \.element.id) { index, option in
                QuizPlayOptionRow(
                    letter: QuizPlayOptionLetter.letter(at: index),
                    text: option.text,
                    isSelected: isOptionSelected(option.id),
                    accent: QuizTheme.draftGlow,
                    action: { onSelectOption(option.id) }
                )
            }
        }
    }

    private var bookmarkButton: some View {
        Button(action: onToggleBookmark) {
            HStack(spacing: 8) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 14, weight: .semibold))
                Text(Strings.QuizBuilder.Preview.bookmark)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(QuizTheme.publishedGlow.opacity(0.95))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.35))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct QuizBuilderPreviewNavigationRow: View {
    let canGoBack: Bool
    let isOnLastQuestion: Bool
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(canGoBack ? .white : QuizTheme.mutedText)
                    .frame(width: 52, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.black.opacity(0.45))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1.2)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canGoBack)

            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text(
                        isOnLastQuestion
                            ? Strings.QuizBuilder.Preview.`continue`
                            : Strings.QuizBuilder.Action.next
                    )
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(QuizTheme.draftGlow)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.45))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(QuizTheme.draftGlow, lineWidth: 1.6)
                )
                .shadow(color: QuizTheme.draftGlow.opacity(0.45), radius: 12, x: 0, y: 0)
            }
            .buttonStyle(.plain)
        }
    }
}

struct QuizBuilderPreviewNumberStrip: View {
    let questionCount: Int
    let currentIndex: Int
    let onSelect: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<questionCount, id: \.self) { index in
                    numberButton(index: index)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 10)
        }
        .background(QuizPlayCardBackground(cornerRadius: 14))
    }

    private func numberButton(index: Int) -> some View {
        let isCurrent = index == currentIndex
        return Button {
            onSelect(index)
        } label: {
            Text("\(index + 1)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(isCurrent ? QuizTheme.draftGlow : QuizTheme.publishedGlow.opacity(0.85))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.black.opacity(0.35))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            isCurrent ? QuizTheme.draftGlow : Color.white.opacity(0.08),
                            lineWidth: isCurrent ? 1.4 : 1
                        )
                )
                .overlay(alignment: .bottom) {
                    if isCurrent {
                        Capsule()
                            .fill(QuizTheme.draftGlow)
                            .frame(width: 14, height: 2)
                            .offset(y: 5)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

typealias QuizBuilderPreviewCardBackground = QuizPlayCardBackground

enum QuizBuilderPreviewOptionLetter {
    static func letter(at index: Int) -> String {
        QuizPlayOptionLetter.letter(at: index)
    }
}
