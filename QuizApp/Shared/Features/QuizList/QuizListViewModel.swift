import Foundation

enum QuizListError: Error {
    case loadFailed
}

@MainActor
protocol QuizListViewModel: ObservableObject {
    var filter: QuizListFilter { get set }
    var searchText: String { get set }
    var selectedQuizID: String? { get set }
    var quizzes: [Quiz] { get }
    var filteredQuizzes: [Quiz] { get }
    var allCount: Int { get }
    var draftCount: Int { get }
    var publishedCount: Int { get }
    var isLoading: Bool { get }
    var error: QuizListError? { get set }
    var canAuthorQuizzes: Bool { get }

    func loadQuizzes() async
    func createQuiz()
    func selectQuiz(_ quiz: Quiz)
    func previewQuiz(_ quiz: Quiz)
    func playQuiz(_ quiz: Quiz)
    func openQuizMenu(quiz: Quiz)
}

@MainActor
final class QuizListViewModelImpl: QuizListViewModel {

    let coordinator: QuizListCoordinator
    private let quizRepository: QuizRepository
    let canAuthorQuizzes: Bool

    @Published var filter: QuizListFilter = .all
    @Published var searchText: String = ""
    @Published var selectedQuizID: String?
    @Published private(set) var quizzes: [Quiz] = []
    @Published private(set) var isLoading: Bool = false
    @Published var error: QuizListError?

    var allCount: Int { quizzes.count }
    var draftCount: Int { quizzes.filter(\.matchesDraftFilter).count }
    var publishedCount: Int { quizzes.filter(\.matchesPublishedFilter).count }

    var filteredQuizzes: [Quiz] {
        quizzes.filter { quiz in
            guard quiz.matchesSearch(searchText) else { return false }
            switch filter {
            case .all:
                return true
            case .drafts:
                return quiz.matchesDraftFilter
            case .published:
                return quiz.matchesPublishedFilter
            }
        }
    }

    init(
        coordinator: QuizListCoordinator,
        quizRepository: QuizRepository = QuizRepositoryMock(),
        canAuthorQuizzes: Bool = true
    ) {
        self.coordinator = coordinator
        self.quizRepository = quizRepository
        self.canAuthorQuizzes = canAuthorQuizzes
    }

    func loadQuizzes() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            quizzes = try await quizRepository.fetchQuizzes()
        } catch {
            Logger.shared.log("Failed to load quizzes: \(error)", level: .error)
            self.error = .loadFailed
        }
    }

    func createQuiz() {
        guard canAuthorQuizzes else { return }
        Task {
            await coordinator.showQuizBuilder()
        }
    }

    func selectQuiz(_ quiz: Quiz) {
        selectedQuizID = quiz.id
    }

    func previewQuiz(_ quiz: Quiz) {
        Logger.shared.log("Preview quiz: \(quiz.title)", level: .info)
        createQuiz()
    }

    func playQuiz(_ quiz: Quiz) {
        Task {
            await coordinator.playQuiz(quiz)
        }
    }

    func openQuizMenu(quiz: Quiz) {
        Logger.shared.log("Quiz menu tapped: \(quiz.title)", level: .info)
    }
}

final class QuizListPreviewViewModel: QuizListViewModel {
    @Published var filter: QuizListFilter = .all
    @Published var searchText: String = ""
    @Published var selectedQuizID: String?
    @Published private(set) var quizzes: [Quiz] = []
    var allCount: Int { quizzes.count }
    var draftCount: Int { quizzes.filter(\.matchesDraftFilter).count }
    var publishedCount: Int { quizzes.filter(\.matchesPublishedFilter).count }
    var filteredQuizzes: [Quiz] {
        quizzes.filter { quiz in
            guard quiz.matchesSearch(searchText) else { return false }
            switch filter {
            case .all: return true
            case .drafts: return quiz.matchesDraftFilter
            case .published: return quiz.matchesPublishedFilter
            }
        }
    }
    var isLoading: Bool = false
    var error: QuizListError?
    let canAuthorQuizzes: Bool = true

    init() {
        Task {
            quizzes = (try? await QuizRepositoryMock().fetchQuizzes()) ?? []
        }
    }

    func loadQuizzes() async {}
    func createQuiz() {}
    func selectQuiz(_ quiz: Quiz) { selectedQuizID = quiz.id }
    func previewQuiz(_ quiz: Quiz) {}
    func playQuiz(_ quiz: Quiz) {}
    func openQuizMenu(quiz: Quiz) {}
}
