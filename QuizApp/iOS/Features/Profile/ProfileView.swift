import SwiftUI

struct ProfileView<ViewModel: ProfileViewModel>: View {

    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.isGuestSession {
                if viewModel.isLoading {
                    CometSpinnerView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    guestContent
                }
            } else if viewModel.isLoading && viewModel.profile == nil {
                CometSpinnerView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let profile = viewModel.profile {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ProfileHeaderView(
                            profile: profile,
                            onSettingsTap: viewModel.openSettings
                        )

                        ProfileQuickStatsCard(profile: profile)

                        ProfileAchievementsSection(
                            achievements: profile.achievements,
                            onSeeAll: viewModel.openAllAchievements
                        )

                        ProfileStatisticsGrid(statistics: profile.statistics)

                        contentSection

                        ProfileActionButtons(
                            shareText: viewModel.shareText,
                            onEdit: viewModel.openEditProfile,
                            showsPublishingActions: viewModel.canPublishContent
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 110)
                }
            } else {
                Text(Strings.Profile.title)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await viewModel.loadProfile()
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ProfileContentTabs(selectedTab: $viewModel.contentTab)

            if viewModel.contentTab == .myQuizzes {
                ProfileQuizStatusChips(
                    filter: $viewModel.quizStatusFilter,
                    draftCount: viewModel.draftCount,
                    publishedCount: viewModel.publishedCount
                )
            }

            contentList
        }
    }

    @ViewBuilder
    private var contentList: some View {
        switch viewModel.contentTab {
        case .myQuizzes, .favorites:
            quizList
        case .history:
            historyList
        }
    }

    @ViewBuilder
    private var quizList: some View {
        let quizzes = viewModel.filteredQuizzes
        if quizzes.isEmpty {
            emptyText(
                viewModel.contentTab == .favorites
                    ? Strings.Profile.Empty.favorites
                    : Strings.Profile.Empty.quizzes
            )
        } else {
            LazyVStack(spacing: 12) {
                ForEach(quizzes) { quiz in
                    QuizCardView(
                        quiz: quiz,
                        onCardTap: { viewModel.openQuizMenu(quiz) },
                        onMenuTap: { viewModel.openQuizMenu(quiz) }
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var historyList: some View {
        if viewModel.history.isEmpty {
            emptyText(Strings.Profile.Empty.history)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.history) { result in
                    ResultCardView(result: result) {
                        viewModel.openResult(result)
                    }
                }
            }
        }
    }

    private var guestContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(Strings.Profile.Guest.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(Strings.Profile.Guest.subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(QuizTheme.mutedText)
                }

                if let summary = viewModel.guestSummary {
                    Text(Strings.Profile.Guest.statisticsTitle)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    ProfileStatisticsGrid(
                        statistics: ProfileStatistics(
                            quizzesCompleted: summary.quizzesCompleted,
                            quizzesCompletedMonthlyDelta: 0,
                            accuracyPercent: summary.averageScorePercent,
                            accuracyMonthlyDelta: 0,
                            quizzesCreated: 0,
                            quizzesCreatedMonthlyDelta: 0,
                            globalRank: summary.globalRank,
                            topPercent: 0
                        )
                    )
                }

                ProfileContentTabs(selectedTab: $viewModel.contentTab)

                if viewModel.contentTab == .myQuizzes {
                    emptyText(Strings.Profile.Guest.emptyQuizzes)
                } else {
                    historyList
                }

                CommonButton(
                    title: Strings.Profile.Guest.register,
                    background: Color(red: 0.29, green: 0.39, blue: 0.92),
                    foreground: .white
                ) {
                    viewModel.openRegistration()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 110)
        }
    }

    private func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(QuizTheme.mutedText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
    }
}

#Preview {
    ProfilePreviewContainer()
}

private struct ProfilePreviewContainer: View {
    @StateObject private var viewModel = ProfilePreviewViewModel()

    var body: some View {
        ZStack {
            QuizListBackgroundView()
            ProfileView(viewModel: viewModel)
        }
    }
}
