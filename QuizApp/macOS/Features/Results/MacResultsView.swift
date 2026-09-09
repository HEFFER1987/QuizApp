import SwiftUI

struct MacResultsView<ViewModel: ResultsViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Strings.ResultsHistory.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            if let summary = viewModel.summary {
                metricsRow(summary)
            }
            ResultsFilterChips(filter: $viewModel.filter)
            resultsContent
        }
        .padding(24)
        .task { await viewModel.loadResults() }
    }

    private func metricsRow(_ summary: ResultsSummary) -> some View {
        HStack(spacing: 12) {
            metricCard(title: "Accuracy", value: "\(summary.averageScorePercent)%")
            metricCard(title: "Quizzes", value: "\(summary.quizzesCompleted)")
            metricCard(title: "Attempts", value: "\(summary.totalAttempts)")
            metricCard(title: "Ranking", value: "#\(summary.globalRank)")
        }
    }

    private func metricCard(title: String, value: String) -> some View {
        MacGlassCard {
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var resultsContent: some View {
        if viewModel.isLoading && viewModel.results.isEmpty {
            SystemLoadingView(message: "Loading...")
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.filteredResults) { result in
                        ResultCardView(result: result) {
                            viewModel.openResult(result)
                        }
                    }
                }
            }
        }
    }
}

struct MacResultDetailSplitView<ViewModel: ResultDetailViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var selectedQuestionID: String?

    var body: some View {
        HSplitView {
            questionList
                .frame(minWidth: 220, idealWidth: 260, maxWidth: 320)
            reviewDetail
                .frame(minWidth: 360)
        }
        .padding(16)
        .task { await viewModel.load() }
        .onAppear {
            selectedQuestionID = viewModel.visibleQuestions.first?.id
        }
    }

    private var questionList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.visibleQuestions) { question in
                    Button {
                        selectedQuestionID = question.id
                    } label: {
                        HStack {
                            Image(systemName: question.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(question.isCorrect ? QuizTheme.excellentGlow : QuizTheme.reviewGlow)
                            Text("Question \(question.number)")
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedQuestionID == question.id
                                      ? QuizTheme.publishedGlow.opacity(0.12)
                                      : Color.black.opacity(0.25))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var reviewDetail: some View {
        if let question = viewModel.visibleQuestions.first(where: { $0.id == selectedQuestionID }) {
            ResultQuestionReviewCard(
                question: question,
                isExplanationExpanded: viewModel.isExplanationExpanded(question.id),
                showsTimelineConnector: false,
                onToggleExplanation: { viewModel.toggleExplanation(question.id) }
            )
        } else {
            SystemEmptyView(title: "Select a question", message: "Choose a question to review")
        }
    }
}

struct MacProfileView<ViewModel: ProfileViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ScrollView {
            if let profile = viewModel.profile {
                VStack(alignment: .leading, spacing: 20) {
                    ProfileHeaderView(profile: profile, onSettingsTap: viewModel.openSettings)
                    ProfileQuickStatsCard(profile: profile)
                    ProfileStatisticsGrid(statistics: profile.statistics)
                    ProfileAchievementsSection(
                        achievements: profile.achievements,
                        onSeeAll: viewModel.openAllAchievements
                    )
                    ProfileActionButtons(shareText: viewModel.shareText, onEdit: viewModel.openEditProfile)
                }
                .padding(24)
            } else if viewModel.isLoading {
                SystemLoadingView(message: "Loading...")
            }
        }
        .task { await viewModel.loadProfile() }
    }
}

struct MacAchievementsView<ViewModel: ProfileViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            if let profile = viewModel.profile {
                Text("Unlocked \(profile.achievementsUnlocked) / \(profile.achievementsTotal)")
                    .foregroundStyle(QuizTheme.mutedText)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(profile.achievements) { achievement in
                        HexagonIconView(
                            systemName: achievement.iconName ?? "star.fill",
                            glowColor: QuizTheme.glowColor(for: achievement.glow.resultIconGlow),
                            size: 72,
                            iconSize: 22
                        )
                        .opacity(achievement.isLocked ? 0.35 : 1)
                    }
                }
            }
            Spacer()
        }
        .padding(24)
        .task { await viewModel.loadProfile() }
    }
}

#Preview {
    MacResultsView(viewModel: ResultsPreviewViewModel())
        .background(Color.black)
}
