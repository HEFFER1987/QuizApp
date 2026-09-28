import SwiftUI

struct MacQuizPlayHeader<ViewModel: QuizPlayViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QuizTheme.publishedGlow)
                Text("QUIZ")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(spacing: 6) {
                Text(viewModel.progressText)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                QuizPlayProgressHeader(
                    currentIndex: viewModel.currentIndex,
                    total: viewModel.questions.count,
                    accent: QuizTheme.publishedGlow,
                    showsNumericLabel: false
                )
                .frame(width: 200)
            }

            Spacer()

            HStack(spacing: 12) {
                elapsedPill
                Button(action: viewModel.dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close quiz")
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private var elapsedPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "stopwatch")
                .font(.system(size: 12, weight: .semibold))
            Text(formatTime(viewModel.elapsedSeconds))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(QuizTheme.draftGlow)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(QuizTheme.draftGlow.opacity(0.12))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(QuizTheme.draftGlow.opacity(0.45), lineWidth: 1)
        )
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }
}

struct MacQuizPlayQuestionsSidebar<ViewModel: QuizPlayViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("Questions")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            } icon: {
                Image(systemName: "list.bullet")
                    .foregroundStyle(QuizTheme.publishedGlow)
            }
            .labelStyle(.titleAndIcon)
            .padding(.horizontal, 4)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.questions.enumerated()), id: \.element.id) { index, question in
                        sidebarRow(index: index, question: question)
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 280)
        .background(QuizPlayCardBackground(cornerRadius: 18))
    }

    private func sidebarRow(index: Int, question: QuizPlayQuestion) -> some View {
        let isCurrent = index == viewModel.currentIndex
        let isAnswered = viewModel.isQuestionAnswered(at: index)

        return Button {
            viewModel.goToQuestion(at: index)
        } label: {
            HStack(alignment: .top, spacing: 10) {
                statusIcon(isCurrent: isCurrent, isAnswered: isAnswered)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(index + 1). \(viewModel.questionListTitle(at: index))")
                        .font(.system(size: 13, weight: isCurrent ? .semibold : .medium, design: .rounded))
                        .foregroundStyle(isCurrent ? .white : QuizTheme.mutedText)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(question.type.title)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(QuizTheme.publishedGlow.opacity(0.75))
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isCurrent ? QuizTheme.publishedGlow.opacity(0.12) : Color.black.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isCurrent ? QuizTheme.publishedGlow.opacity(0.7) : Color.white.opacity(0.06),
                        lineWidth: isCurrent ? 1.4 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func statusIcon(isCurrent: Bool, isAnswered: Bool) -> some View {
        if isAnswered {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(QuizTheme.excellentGlow)
        } else if isCurrent {
            Image(systemName: "circle.inset.filled")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(QuizTheme.publishedGlow)
        } else {
            Image(systemName: "circle")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.35))
        }
    }
}

struct MacQuizPlayQuestionPanel<ViewModel: QuizPlayViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    let question: QuizPlayQuestion

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    categoryPill
                    Text(question.prompt)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    if let code = question.codeSnippet, !code.isEmpty {
                        QuizCodeSnippetView(code: code)
                    }

                    optionsList
                }
                .padding(24)
            }

            footerBar
        }
        .background(QuizPlayCardBackground(cornerRadius: 20))
    }

    @ViewBuilder
    private var categoryPill: some View {
        if let category = question.categoryLabel, !category.isEmpty {
            HStack(spacing: 6) {
                Image(systemName: viewModel.iconName)
                    .font(.system(size: 11, weight: .semibold))
                Text(category)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(QuizTheme.publishedGlow)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(QuizTheme.publishedGlow.opacity(0.12))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(QuizTheme.publishedGlow.opacity(0.35), lineWidth: 1)
            )
        }
    }

    private var optionsList: some View {
        VStack(spacing: 10) {
            ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                QuizPlayOptionRow(
                    letter: QuizPlayOptionLetter.letter(at: index),
                    text: option.text,
                    isSelected: viewModel.selectedOptionIDs.contains(option.id),
                    accent: QuizTheme.publishedGlow,
                    action: { viewModel.selectOption(option.id) }
                )
            }
        }
    }

    private var footerBar: some View {
        HStack(spacing: 12) {
            Label {
                Text(Strings.QuizBuilder.Preview.tip)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
                    .lineLimit(2)
            } icon: {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(QuizTheme.mutedText)
            }
            .labelStyle(.titleAndIcon)

            Spacer()

            Button(action: viewModel.resetCurrentQuestion) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.black.opacity(0.35))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reset answer")

            Button(action: viewModel.goBack) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                    Text("Previous")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(viewModel.canGoBack ? .white : QuizTheme.mutedText)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.35))
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canGoBack)

            Button(action: viewModel.goNext) {
                HStack(spacing: 6) {
                    Text(viewModel.isOnLastQuestion ? "Finish" : "Next")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(QuizTheme.publishedGlow.opacity(0.25))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(QuizTheme.publishedGlow, lineWidth: 1.4)
                )
                .shadow(color: QuizTheme.publishedGlow.opacity(0.35), radius: 8, x: 0, y: 0)
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canConfirm)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.2))
    }
}
