import Foundation

protocol ExploreCoordinator {
    func showPublicQuizDetail(quizID: String) async
    func startQuiz(quizID: String) async
}

enum ExploreError: Error {
    case loadFailed
}

@MainActor
protocol ExploreViewModel: ObservableObject {
    var searchText: String { get set }
    var selectedCategory: ExploreCategory? { get set }
    var quizzes: [ExploreQuiz] { get }
    var filteredQuizzes: [ExploreQuiz] { get }
    var isLoading: Bool { get }
    var error: ExploreError? { get set }

    func load() async
    func openQuiz(_ quiz: ExploreQuiz)
    func startQuiz(_ quiz: ExploreQuiz)
}

@MainActor
final class ExploreViewModelImpl: ExploreViewModel {
    let coordinator: ExploreCoordinator
    private let repository: ExploreRepository

    @Published var searchText: String = ""
    @Published var selectedCategory: ExploreCategory?
    @Published private(set) var quizzes: [ExploreQuiz] = []
    @Published private(set) var isLoading: Bool = false
    @Published var error: ExploreError?

    var filteredQuizzes: [ExploreQuiz] {
        quizzes.filter { quiz in
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let matchesSearch = query.isEmpty
                || quiz.title.lowercased().contains(query)
                || quiz.categoryLabel.lowercased().contains(query)
            let matchesCategory: Bool
            if let selectedCategory {
                matchesCategory = quiz.categoryLabel.lowercased().contains(selectedCategory.title.lowercased())
            } else {
                matchesCategory = true
            }
            return matchesSearch && matchesCategory
        }
    }

    init(
        coordinator: ExploreCoordinator,
        repository: ExploreRepository = ExploreRepositoryMock()
    ) {
        self.coordinator = coordinator
        self.repository = repository
    }

    func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            quizzes = try await repository.fetchPopularQuizzes()
        } catch {
            self.error = .loadFailed
        }
    }

    func openQuiz(_ quiz: ExploreQuiz) {
        Task {
            await coordinator.showPublicQuizDetail(quizID: quiz.id)
        }
    }

    func startQuiz(_ quiz: ExploreQuiz) {
        Task {
            await coordinator.startQuiz(quizID: quiz.id)
        }
    }
}
