import SwiftUI

struct MacMotivationCard: View {
    var body: some View {
        MacGlassCard(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Small steps create big results")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Keep going! Your next level is closer than you think.")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 40)
            .background(
                Image(asset: Asset.background)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.35)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            )
        }
    }
}

struct MacProfileInspectorView<ViewModel: ProfileViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let profile = viewModel.profile {
                    compactHeader(profile)
                    levelCard(profile)
                    ProfileQuickStatsCard(profile: profile)
                    ProfileAchievementsSection(
                        achievements: profile.achievements,
                        onSeeAll: viewModel.openAllAchievements
                    )
                    MacMotivationCard()
                } else if viewModel.isLoading {
                    SystemLoadingView(message: "Loading...")
                }
            }
            .padding(16)
        }
        .task {
            await viewModel.loadProfile()
        }
    }

    private func compactHeader(_ profile: UserProfile) -> some View {
        HStack(spacing: 10) {
            Image(systemName: profile.avatarSystemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(QuizTheme.draftGlow)
                .frame(width: 36, height: 36)
                .background(Circle().fill(QuizTheme.cardFill))
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(profile.handle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
            }
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(QuizTheme.mutedText)
        }
    }

    private func levelCard(_ profile: UserProfile) -> some View {
        MacGlassCard {
            VStack(spacing: 12) {
                HStack {
                    ScoreProgressRing(
                        progress: profile.xpProgress,
                        percentText: "Lv \(profile.level)",
                        caption: profile.titleBadge,
                        size: 72
                    )
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 6) {
                    ProgressView(value: profile.xpProgress)
                        .tint(QuizTheme.publishedGlow)
                    Text(Strings.Profile.Xp.progress(profile.currentXP, profile.levelXP))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(QuizTheme.mutedText)
                }
            }
        }
    }
}

#Preview {
    MacProfileInspectorView(viewModel: MacProfileInspectorPreviewViewModel())
        .frame(width: 320, height: 700)
        .background(Color.black)
}

private final class MacProfileInspectorPreviewViewModel: ProfileViewModel {
    @Published private(set) var profile: UserProfile?
    @Published private(set) var quizzes: [Quiz] = []
    @Published private(set) var history: [QuizResult] = []
    @Published var contentTab: ProfileContentTab = .myQuizzes
    @Published var quizStatusFilter: ProfileQuizStatusFilter = .published
    @Published private(set) var isLoading = false
    @Published var error: ProfileError?
    var filteredQuizzes: [Quiz] { [] }
    var draftCount: Int { 0 }
    var publishedCount: Int { 0 }
    var shareText: String { "" }
    let isGuestSession: Bool = false
    var guestSummary: ResultsSummary?
    var canPublishContent: Bool { true }

    init() {
        Task {
            profile = try? await ProfileRepositoryMock().fetchProfile()
        }
    }

    func loadProfile() async {}
    func openSettings() {}
    func openEditProfile() {}
    func openAllAchievements() {}
    func openResult(_ result: QuizResult) {}
    func openQuizMenu(_ quiz: Quiz) {}
    func openRegistration() {}
}
