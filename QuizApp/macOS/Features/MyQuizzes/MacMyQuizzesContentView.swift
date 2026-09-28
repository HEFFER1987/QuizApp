import SwiftUI

struct MacQuizFilterPills<ViewModel: QuizListViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        HStack(spacing: 10) {
            pill(title: "All (\(viewModel.allCount))", filter: .all)
            pill(title: "Drafts (\(viewModel.draftCount))", filter: .drafts)
            pill(title: "Published (\(viewModel.publishedCount))", filter: .published)
            Spacer()
        }
    }

    private func pill(title: String, filter: QuizListFilter) -> some View {
        let isSelected = viewModel.filter == filter
        return Button {
            viewModel.filter = filter
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? QuizTheme.publishedGlow : QuizTheme.mutedText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? QuizTheme.publishedGlow.opacity(0.12) : QuizTheme.cardFill)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? QuizTheme.publishedGlow : Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct MacQuizRowView: View {
    let quiz: Quiz
    let isSelected: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void
    let onPlay: () -> Void
    let onMenu: () -> Void

    private var glowColor: Color { QuizTheme.glowColor(for: quiz.status) }

    var body: some View {
        HStack(spacing: 14) {
            iconView
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(quiz.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    statusBadge
                    Spacer()
                    actionButtons
                }
                if let categoryLabel = quiz.categoryLabel {
                    Text(categoryLabel)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(QuizTheme.mutedText)
                }
                Text(quiz.inlineStatsText)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(QuizTheme.cardFill.opacity(isSelected ? 0.95 : 0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isSelected ? QuizTheme.publishedGlow : glowColor.opacity(0.45),
                    lineWidth: isSelected ? 1.8 : 1
                )
        )
        .shadow(color: isSelected ? QuizTheme.publishedGlow.opacity(0.25) : .clear, radius: 10)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture(perform: onSelect)
    }

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(glowColor.opacity(0.15))
                .frame(width: 52, height: 52)
            Image(systemName: quiz.iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(glowColor)
        }
    }

    private var statusBadge: some View {
        Text(quiz.status == .draft ? Strings.QuizList.Status.draft : Strings.QuizList.Status.published)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(glowColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(glowColor.opacity(0.15)))
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            if quiz.status == .published {
                Button(action: onPlay) {
                    Image(systemName: "play.fill")
                        .foregroundStyle(QuizTheme.publishedGlow)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: onPreview) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundStyle(QuizTheme.draftGlow)
                }
                .buttonStyle(.plain)
            }
            Button(action: onMenu) {
                Image(systemName: "ellipsis")
                    .foregroundStyle(QuizTheme.mutedText)
            }
            .buttonStyle(.plain)
        }
    }
}

struct MacMyQuizzesContentView<ViewModel: QuizListViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    let isOffline: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            if isOffline {
                SystemOfflineBanner(message: "You're offline. Some features may be unavailable.")
            }
            toolbar
            MacQuizFilterPills(viewModel: viewModel)
            listContent
        }
        .padding(24)
        .task {
            await viewModel.loadQuizzes()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Strings.QuizList.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Create, manage and track your quizzes")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
        }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            CommonSearchField(
                placeholder: "Search your quizzes...",
                text: $viewModel.searchText
            )
            Button {
                viewModel.createQuiz()
            } label: {
                Label("Create Quiz", systemImage: "plus")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(QuizTheme.publishedGlow)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var listContent: some View {
        if viewModel.isLoading && viewModel.quizzes.isEmpty {
            SystemLoadingView(message: "Loading...")
        } else if let error = viewModel.error {
            SystemErrorView(
                title: "Something went wrong",
                message: "Unable to load quizzes.",
                retryTitle: "Try Again",
                onRetry: { Task { await viewModel.loadQuizzes() } }
            )
        } else if viewModel.filteredQuizzes.isEmpty {
            SystemEmptyView(
                title: "No quizzes yet",
                message: "Create your first QUIZ",
                actionTitle: "+ Create QUIZ",
                action: { viewModel.createQuiz() }
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredQuizzes) { quiz in
                        MacQuizRowView(
                            quiz: quiz,
                            isSelected: viewModel.selectedQuizID == quiz.id,
                            onSelect: {
                                viewModel.selectQuiz(quiz)
                                if quiz.status == .published {
                                    viewModel.playQuiz(quiz)
                                } else {
                                    viewModel.previewQuiz(quiz)
                                }
                            },
                            onPreview: { viewModel.previewQuiz(quiz) },
                            onPlay: { viewModel.playQuiz(quiz) },
                            onMenu: { viewModel.openQuizMenu(quiz: quiz) }
                        )
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    MacMyQuizzesContentView(
        viewModel: QuizListPreviewViewModel(),
        isOffline: false
    )
    .background(Color.black)
}
