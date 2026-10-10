import SwiftUI

struct QuizPlayView<ViewModel: QuizPlayViewModel>: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            QuizListBackgroundView()
            content
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isComplete, let result = viewModel.sessionResult {
            QuizPlaySessionResultView(result: result, viewModel: viewModel)
        } else if viewModel.isLoading {
            VStack {
                Spacer()
                CometSpinnerView()
                Text(Strings.QuizPlay.loading)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
                    .padding(.top, 12)
                Spacer()
            }
        } else if let question = viewModel.currentQuestion {
            playContent(question: question)
        } else if viewModel.error != nil {
            SystemErrorView(
                title: Strings.QuizPlay.Error.title,
                message: Strings.QuizPlay.Error.message,
                retryTitle: Strings.QuizPlay.Error.retry,
                onRetry: { Task { await viewModel.load() } }
            )
            .padding(20)
        }
    }

    private func playContent(question: QuizPlayQuestion) -> some View {
        let progressValue = Double(viewModel.currentIndex + 1) / Double(max(viewModel.questions.count, 1))

        return ScrollView {
            VStack(spacing: 16) {
                QuizPlayHeaderView(
                    progressText: viewModel.progressText,
                    progressValue: progressValue,
                    elapsedSeconds: viewModel.elapsedSeconds,
                    onClose: viewModel.dismiss
                )

                QuizPlayCategoryBadge(title: viewModel.quizTitle)

                Text(question.prompt)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                if let code = question.codeSnippet, !code.isEmpty {
                    QuizPlayCodeSnippetView(code: code)
                }

                VStack(spacing: 12) {
                    ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                        let letter = optionLetter(for: index)
                        QuizPlayAnswerOptionRow(
                            letter: letter,
                            text: option.text,
                            state: viewModel.optionState(for: option.id),
                            explanation: question.explanation,
                            showsExplanation: viewModel.shouldShowExplanation(for: option.id)
                        )
                        .onTapGesture {
                            viewModel.selectOption(option.id)
                        }
                    }
                }

                QuizPlayHintsPanel(hintsRemaining: viewModel.hintsRemaining)

                QuizPlayPrimaryButton(
                    title: viewModel.submitButtonTitle,
                    isEnabled: viewModel.canConfirm,
                    action: viewModel.confirmAnswer
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private func optionLetter(for index: Int) -> String {
        guard let scalar = UnicodeScalar(65 + index) else { return "?" }
        return String(Character(scalar))
    }
}

#Preview {
    QuizPlayView(
        viewModel: QuizPlayViewModelImpl(
            quizID: "1",
            coordinator: QuizPlayPreviewCoordinator()
        )
    )
}

private final class QuizPlayPreviewCoordinator: QuizPlayCoordinator {
    func showSessionResult(_ result: QuizPlaySessionResult) async {}
    func dismiss() async {}
}
