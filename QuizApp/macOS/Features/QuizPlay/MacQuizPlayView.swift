import SwiftUI

struct MacQuizPlayView<ViewModel: QuizPlayViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        Group {
            if viewModel.isComplete, let result = viewModel.sessionResult {
                MacQuizSessionResultView(result: result, viewModel: viewModel)
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
        .padding(24)
        .task { await viewModel.load() }
        .onAppear { isFocused = true }
        .focusable()
        .onKeyPress(keys: [.return]) { _ in
            if viewModel.canConfirm { viewModel.confirmAnswer() }
            return .handled
        }
        .onKeyPress(keys: [.leftArrow]) { _ in
            if viewModel.canGoBack { viewModel.goBack() }
            return .handled
        }
        .onKeyPress(keys: [.rightArrow]) { _ in
            if viewModel.canConfirm { viewModel.confirmAnswer() }
            return .handled
        }
    }

    private func playContent(question: QuizPlayQuestion) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(viewModel.quizTitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text(viewModel.progressText)
                    .foregroundStyle(QuizTheme.mutedText)
            }
            ProgressView(value: Double(viewModel.currentIndex + 1), total: Double(max(viewModel.questions.count, 1)))
                .tint(QuizTheme.publishedGlow)
            Text(formatTime(viewModel.elapsedSeconds))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
            Text(question.prompt)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            VStack(spacing: 10) {
                ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                    Button {
                        viewModel.selectOption(option.id)
                    } label: {
                        HStack {
                            Text("\(index + 1).")
                                .foregroundStyle(QuizTheme.publishedGlow)
                            Text(option.text)
                                .foregroundStyle(.white)
                            Spacer()
                            if viewModel.selectedOptionIDs.contains(option.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(QuizTheme.publishedGlow)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(QuizTheme.cardFill)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            HStack {
                Spacer()
                Button("Confirm", action: viewModel.confirmAnswer)
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.canConfirm)
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }
}

struct MacQuizSessionResultView<ViewModel: QuizPlayViewModel>: View {
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
            Text("Great job!")
                .foregroundStyle(QuizTheme.publishedGlow)
            HStack(spacing: 20) {
                Label("+\(result.xpEarned) XP", systemImage: "star.fill")
                Label("\(result.coinsEarned) Coins", systemImage: "bitcoinsign.circle")
            }
            .foregroundStyle(.white)
            if result.leveledUp, let level = result.newLevel {
                Text("Level up → \(level)")
                    .foregroundStyle(QuizTheme.excellentGlow)
            }
            HStack(spacing: 12) {
                Button("Review Answers", action: viewModel.reviewAnswers)
                Button("Retry", action: viewModel.retry)
                ShareLink(item: "\(result.quizTitle): \(result.scorePercent)%") {
                    Text("Share Result")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MacQuizPlayView(viewModel: QuizPlayViewModelImpl(quizID: "1", coordinator: MacQuizPlayCoordinatorImpl()))
        .background(Color.black)
}
