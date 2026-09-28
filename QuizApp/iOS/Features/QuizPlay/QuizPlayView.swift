import SwiftUI

struct QuizPlayView<ViewModel: QuizPlayViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            QuizListBackgroundView()

            Group {
                if viewModel.isComplete, let result = viewModel.sessionResult {
                    QuizPlaySessionResultView(result: result, viewModel: viewModel)
                } else if viewModel.isLoading {
                    SystemLoadingView(message: "Loading quiz...")
                } else if let question = viewModel.currentQuestion {
                    playContent(question: question)
                } else if viewModel.error != nil {
                    SystemErrorView(
                        title: "Something went wrong",
                        message: "Unable to load quiz.",
                        retryTitle: "Try Again",
                        onRetry: { Task { await viewModel.load() } }
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.quizTitle)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            ToolbarItem(placement: .topBarTrailing) {
                elapsedLabel
            }
        }
        .task { await viewModel.load() }
    }

    private var elapsedLabel: some View {
        Text(formatTime(viewModel.elapsedSeconds))
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(QuizTheme.draftGlow)
    }

    private func playContent(question: QuizPlayQuestion) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                QuizPlayProgressHeader(
                    currentIndex: viewModel.currentIndex,
                    total: viewModel.questions.count,
                    accent: QuizTheme.publishedGlow
                )

                if let category = question.categoryLabel, !category.isEmpty {
                    categoryPill(category)
                }

                Text(question.prompt)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let code = question.codeSnippet, !code.isEmpty {
                    QuizCodeSnippetView(code: code)
                }

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

                questionNumberStrip

                navigationRow
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private func categoryPill(_ category: String) -> some View {
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
    }

    private var questionNumberStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<viewModel.questions.count, id: \.self) { index in
                    let isCurrent = index == viewModel.currentIndex
                    let isAnswered = viewModel.isQuestionAnswered(at: index)
                    Button {
                        viewModel.goToQuestion(at: index)
                    } label: {
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(
                                isCurrent ? QuizTheme.publishedGlow : QuizTheme.mutedText
                            )
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.black.opacity(0.35))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(
                                        isCurrent ? QuizTheme.publishedGlow : Color.white.opacity(0.08),
                                        lineWidth: isCurrent ? 1.4 : 1
                                    )
                            )
                            .overlay(alignment: .topTrailing) {
                                if isAnswered {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(QuizTheme.excellentGlow)
                                        .offset(x: 4, y: -4)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var navigationRow: some View {
        HStack(spacing: 12) {
            Button(action: viewModel.resetCurrentQuestion) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.black.opacity(0.45))
                    )
            }
            .buttonStyle(.plain)

            Button(action: viewModel.goBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(viewModel.canGoBack ? .white : QuizTheme.mutedText)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.black.opacity(0.45))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canGoBack)

            Button(action: viewModel.goNext) {
                HStack(spacing: 8) {
                    Text(viewModel.isOnLastQuestion ? "Finish" : "Next")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(QuizTheme.publishedGlow.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(QuizTheme.publishedGlow, lineWidth: 1.4)
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canConfirm)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }
}

private struct QuizPlaySessionResultView<ViewModel: QuizPlayViewModel>: View {
    let result: QuizPlaySessionResult
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 18) {
            Text("QUIZ COMPLETE")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
            Text("\(result.scorePercent)%")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("\(result.correctCount) / \(result.totalCount)")
                .foregroundStyle(.white)
            HStack(spacing: 12) {
                Button("Review Answers", action: viewModel.reviewAnswers)
                Button("Retry", action: viewModel.retry)
            }
        }
        .padding(24)
    }
}

#Preview {
    NavigationStack {
        QuizPlayView(
            viewModel: QuizPlayViewModelImpl(
                quizID: "1",
                coordinator: QuizPlayCoordinatorPreviewStub()
            )
        )
    }
}

private final class QuizPlayCoordinatorPreviewStub: QuizPlayCoordinator {
    func showSessionResult(_ result: QuizPlaySessionResult) async {}
    func dismiss() async {}
}
