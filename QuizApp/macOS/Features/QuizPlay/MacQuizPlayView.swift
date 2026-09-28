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
            } else {
                SystemLoadingView(message: "Loading quiz...")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MacSpaceBackgroundView())
        .onAppear { isFocused = true }
        .focusable()
        .onKeyPress(keys: [.return]) { _ in
            if viewModel.canConfirm { viewModel.goNext() }
            return .handled
        }
        .onKeyPress(keys: [.leftArrow]) { _ in
            if viewModel.canGoBack { viewModel.goBack() }
            return .handled
        }
        .onKeyPress(keys: [.rightArrow]) { _ in
            if viewModel.canConfirm { viewModel.goNext() }
            return .handled
        }
    }

    private func playContent(question: QuizPlayQuestion) -> some View {
        VStack(spacing: 0) {
            MacQuizPlayHeader(viewModel: viewModel)

            HStack(alignment: .top, spacing: 16) {
                MacQuizPlayQuestionPanel(viewModel: viewModel, question: question)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                MacQuizPlayQuestionsSidebar(viewModel: viewModel)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
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
        .padding(24)
    }
}

#Preview {
    MacQuizPlayPreviewHost()
        .background(MacSpaceBackgroundView())
        .frame(width: 1100, height: 720)
}

private struct MacQuizPlayPreviewHost: View {
    @StateObject private var viewModel = QuizPlayViewModelImpl(
        quizID: "1",
        coordinator: MacQuizPlayCoordinatorImpl()
    )

    var body: some View {
        MacQuizPlayView(viewModel: viewModel)
            .task { await viewModel.load() }
    }
}
