import SwiftUI

struct QuizListView<ViewModel: QuizListViewModel>: View {

    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            CommonSearchField(
                placeholder: Strings.QuizList.Search.placeholder,
                text: $viewModel.searchText
            )
            FilterTabBar(filter: $viewModel.filter)
            quizListContent
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .overlay(alignment: .bottomTrailing) {
            FloatingActionButton {
                viewModel.createQuiz()
            }
            .padding(.trailing, 20)
            .padding(.bottom, 84)
        }
        .task {
            await viewModel.loadQuizzes()
        }
    }

    private var headerView: some View {
        HStack {
            Text(Strings.QuizList.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Button {
                viewModel.createQuiz()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(QuizTheme.cardFill))
                    .overlay(
                        Circle()
                            .stroke(QuizTheme.draftGlow.opacity(0.85), lineWidth: 1.5)
                    )
                    .shadow(color: QuizTheme.draftGlow.opacity(0.45), radius: 8, x: 0, y: 0)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var quizListContent: some View {
        if viewModel.isLoading && viewModel.quizzes.isEmpty {
            Spacer()
            ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity)
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.filteredQuizzes) { quiz in
                        QuizCardView(quiz: quiz) {
                            viewModel.openQuizMenu(quiz: quiz)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    QuizListPreviewContainer()
}

private struct QuizListPreviewContainer: View {
    @StateObject private var viewModel = QuizListPreviewViewModel()

    var body: some View {
        ZStack {
            QuizListBackgroundView()
            QuizListView(viewModel: viewModel)
        }
    }
}
