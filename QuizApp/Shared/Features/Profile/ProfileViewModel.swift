import Foundation

enum ProfileError: Error {
    case loadFailed
}

@MainActor
protocol ProfileViewModel: ObservableObject {
    var profile: UserProfile? { get }
    var quizzes: [Quiz] { get }
    var history: [QuizResult] { get }
    var contentTab: ProfileContentTab { get set }
    var quizStatusFilter: ProfileQuizStatusFilter { get set }
    var isLoading: Bool { get }
    var error: ProfileError? { get set }
    var shareText: String { get }

    var filteredQuizzes: [Quiz] { get }
    var draftCount: Int { get }
    var publishedCount: Int { get }

    func loadProfile() async
    func openSettings()
    func openEditProfile()
    func openAllAchievements()
    func openResult(_ result: QuizResult)
    func openQuizMenu(_ quiz: Quiz)
}

@MainActor
final class ProfileViewModelImpl: ProfileViewModel {

    let coordinator: ProfileCoordinator
    private let profileRepository: ProfileRepository
    private let quizRepository: QuizRepository
    private let resultsRepository: ResultsRepository

    @Published private(set) var profile: UserProfile?
    @Published private(set) var quizzes: [Quiz] = []
    @Published private(set) var history: [QuizResult] = []
    @Published var contentTab: ProfileContentTab = .myQuizzes
    @Published var quizStatusFilter: ProfileQuizStatusFilter = .published
    @Published private(set) var isLoading: Bool = false
    @Published var error: ProfileError?

    var draftCount: Int {
        quizzes.filter(\.matchesDraftFilter).count
    }

    var publishedCount: Int {
        quizzes.filter(\.matchesPublishedFilter).count
    }

    var filteredQuizzes: [Quiz] {
        switch contentTab {
        case .myQuizzes:
            return quizzes.filter { quiz in
                switch quizStatusFilter {
                case .drafts:
                    return quiz.matchesDraftFilter
                case .published:
                    return quiz.matchesPublishedFilter
                }
            }
        case .favorites:
            return profile?.favorites ?? []
        case .history:
            return []
        }
    }

    var shareText: String {
        guard let profile else { return "" }
        return Strings.Profile.shareText(
            profile.displayName,
            profile.handle,
            profile.level,
            profile.statistics.quizzesCompleted
        )
    }

    init(
        coordinator: ProfileCoordinator,
        profileRepository: ProfileRepository = ProfileRepositoryMock(),
        quizRepository: QuizRepository = QuizRepositoryMock(),
        resultsRepository: ResultsRepository = ResultsRepositoryMock()
    ) {
        self.coordinator = coordinator
        self.profileRepository = profileRepository
        self.quizRepository = quizRepository
        self.resultsRepository = resultsRepository
    }

    func loadProfile() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            async let fetchedProfile = profileRepository.fetchProfile()
            async let fetchedQuizzes = quizRepository.fetchQuizzes()
            async let fetchedHistory = resultsRepository.fetchResults()
            profile = try await fetchedProfile
            quizzes = try await fetchedQuizzes
            history = try await fetchedHistory
        } catch {
            Logger.shared.log("Failed to load profile: \(error)", level: .error)
            self.error = .loadFailed
        }
    }

    func openSettings() {
        coordinator.openSettings()
    }

    func openEditProfile() {
        coordinator.openEditProfile()
    }

    func openAllAchievements() {
        coordinator.openAllAchievements()
    }

    func openResult(_ result: QuizResult) {
        coordinator.openResult(result)
    }

    func openQuizMenu(_ quiz: Quiz) {
        Logger.shared.log("Quiz menu tapped: \(quiz.id)", level: .info)
    }
}

final class ProfilePreviewViewModel: ProfileViewModel {
    @Published private(set) var profile: UserProfile?
    @Published private(set) var quizzes: [Quiz] = []
    @Published private(set) var history: [QuizResult] = []
    @Published var contentTab: ProfileContentTab = .myQuizzes
    @Published var quizStatusFilter: ProfileQuizStatusFilter = .published
    @Published private(set) var isLoading: Bool = false
    @Published var error: ProfileError?

    var draftCount: Int {
        quizzes.filter(\.matchesDraftFilter).count
    }

    var publishedCount: Int {
        quizzes.filter(\.matchesPublishedFilter).count
    }

    var filteredQuizzes: [Quiz] {
        switch contentTab {
        case .myQuizzes:
            return quizzes.filter { quiz in
                switch quizStatusFilter {
                case .drafts:
                    return quiz.matchesDraftFilter
                case .published:
                    return quiz.matchesPublishedFilter
                }
            }
        case .favorites:
            return profile?.favorites ?? []
        case .history:
            return []
        }
    }

    var shareText: String {
        guard let profile else { return "" }
        return Strings.Profile.shareText(
            profile.displayName,
            profile.handle,
            profile.level,
            profile.statistics.quizzesCompleted
        )
    }

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        do {
            profile = try await ProfileRepositoryMock().fetchProfile()
            quizzes = try await QuizRepositoryMock().fetchQuizzes()
            history = try await ResultsRepositoryMock().fetchResults()
        } catch {
            self.error = .loadFailed
        }
    }

    func openSettings() {}
    func openEditProfile() {}
    func openAllAchievements() {}
    func openResult(_ result: QuizResult) {}
    func openQuizMenu(_ quiz: Quiz) {}
}
