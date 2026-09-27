import SwiftUI

struct MacExploreView<ViewModel: ExploreViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Strings.MainTab.explore)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            CommonSearchField(placeholder: "Search quizzes...", text: $viewModel.searchText)
            categoryChips
            Text("Popular")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            exploreList
        }
        .padding(24)
        .task { await viewModel.load() }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(title: "All", category: nil)
                ForEach(ExploreCategory.allCases) { category in
                    categoryChip(title: category.title, category: category)
                }
            }
        }
    }

    private func categoryChip(title: String, category: ExploreCategory?) -> some View {
        let isSelected = viewModel.selectedCategory == category
        return Button {
            viewModel.selectedCategory = category
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(isSelected ? QuizTheme.publishedGlow.opacity(0.2) : QuizTheme.cardFill))
                .foregroundStyle(isSelected ? QuizTheme.publishedGlow : QuizTheme.mutedText)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var exploreList: some View {
        if viewModel.isLoading {
            SystemLoadingView(message: "Loading...")
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredQuizzes) { quiz in
                        MacExploreQuizRow(quiz: quiz) {
                            viewModel.openQuiz(quiz)
                        } onStart: {
                            viewModel.startQuiz(quiz)
                        }
                    }
                }
            }
        }
    }
}

private struct MacExploreQuizRow: View {
    let quiz: ExploreQuiz
    let onOpen: () -> Void
    let onStart: () -> Void

    var body: some View {
        MacGlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(quiz.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(quiz.categoryLabel)
                        .font(.system(size: 13))
                        .foregroundStyle(QuizTheme.mutedText)
                    Text("\(quiz.questionCount) questions · \(quiz.attemptCount) attempts")
                        .font(.system(size: 12))
                        .foregroundStyle(QuizTheme.mutedText)
                }
                Spacer()
                Button("Details", action: onOpen)
                Button("Start", action: onStart)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct MacPublicQuizDetailView<ViewModel: ExploreViewModel>: View {
    let quizID: String
    @ObservedObject var exploreViewModel: ViewModel
    let onStart: () -> Void
    @State private var quiz: ExploreQuiz?

    var body: some View {
        ScrollView {
            if let quiz {
                VStack(alignment: .leading, spacing: 16) {
                    Text(quiz.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(quiz.questionCount) Questions · \(quiz.difficulty)")
                        .foregroundStyle(QuizTheme.mutedText)
                    Text("About")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(quiz.about)
                        .foregroundStyle(QuizTheme.mutedText)
                    if let best = quiz.bestScorePercent {
                        Text("Best score: \(best)%")
                            .foregroundStyle(QuizTheme.publishedGlow)
                    }
                    Button("Start Quiz", action: onStart)
                        .buttonStyle(.borderedProminent)
                    Text("Created by \(quiz.authorHandle)")
                        .foregroundStyle(QuizTheme.mutedText)
                }
                .padding(24)
            } else {
                SystemLoadingView(message: "Loading...")
            }
        }
        .task {
            quiz = try? await ExploreRepositoryMock().fetchQuiz(id: quizID)
        }
    }
}

#Preview {
    MacExploreView(viewModel: ExploreViewModelImpl(coordinator: ExploreCoordinatorImpl()))
        .background(Color.black)
}
