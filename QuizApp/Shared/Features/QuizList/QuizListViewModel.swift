import Foundation

enum QuizListError: Error {
    case loadFailed
}

@MainActor
protocol QuizListViewModel: ObservableObject {
    var filter: QuizListFilter { get set }
    var searchText: String { get set }
    var quizzes: [Quiz] { get }
    var filteredQuizzes: [Quiz] { get }
    var isLoading: Bool { get }
    var error: QuizListError? { get set }

    func loadQuizzes() async
    func createQuiz()
    func openQuizMenu(quiz: Quiz)
}

@MainActor
final class QuizListViewModelImpl: QuizListViewModel {

    let coordinator: QuizListCoordinator
    private let quizRepository: QuizRepository

    @Published var filter: QuizListFilter = .all
    @Published var searchText: String = ""
    @Published private(set) var quizzes: [Quiz] = []
    @Published private(set) var isLoading: Bool = false
    @Published var error: QuizListError?

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
        quizRepository: QuizRepository = QuizRepositoryMock()
    ) {
        self.coordinator = coordinator
        self.quizRepository = quizRepository
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
        Task {
            await coordinator.showQuizBuilder()
        }
    }

    func openQuizMenu(quiz: Quiz) {
        Logger.shared.log("Quiz menu tapped: \(quiz.title)", level: .info)
    }
}

final class QuizListPreviewViewModel: QuizListViewModel {
    @Published var filter: QuizListFilter = .all
    @Published var searchText: String = ""
    @Published private(set) var quizzes: [Quiz] = QuizListPreviewViewModel.sampleQuizzes
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

    func loadQuizzes() async {}
    func createQuiz() {}
    func openQuizMenu(quiz: Quiz) {}

    private static let sampleQuizzes: [Quiz] = {
        let now = Date()
        let calendar = Calendar.current
        return [
            Quiz(
                id: "1",
                title: "English Grammar",
                subtitle: "Intermediate",
                questionCount: 12,
                status: .draft,
                iconName: "book.fill",
                updatedAt: calendar.date(byAdding: .hour, value: -2, to: now),
                attemptCount: nil,
                averageScorePercent: nil
            ),
            Quiz(
                id: "2",
                title: "World History",
                subtitle: nil,
                questionCount: 20,
                status: .published,
                iconName: "globe.americas.fill",
                updatedAt: nil,
                attemptCount: 24,
                averageScorePercent: 82
            ),
            Quiz(
                id: "3",
                title: "Swift Basics",
                subtitle: nil,
                questionCount: 15,
                status: .draft,
                iconName: "chevron.left.forwardslash.chevron.right",
                updatedAt: calendar.date(byAdding: .day, value: -1, to: now),
                attemptCount: nil,
                averageScorePercent: nil
            )
        ]
    }()
}
