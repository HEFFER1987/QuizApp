import Foundation

struct GuestResultsRepository: ResultsRepository {
    private let store: GuestProgressStore

    init(store: GuestProgressStore = .shared) {
        self.store = store
    }

    func fetchResults() async throws -> [QuizResult] {
        store.fetchResults()
    }

    func fetchSummary() async throws -> ResultsSummary {
        store.fetchSummary()
    }

    func fetchResultDetail(id: String) async throws -> QuizResultDetail {
        guard let result = store.fetchResults().first(where: { $0.id == id }) else {
            throw ResultsRepositoryError.notFound
        }
        return QuizResultDetail(
            result: result,
            difficulty: .medium,
            questions: []
        )
    }
}
