import Foundation

enum ResultsError: Error {
    case loadFailed
}

@MainActor
protocol ResultsViewModel: ObservableObject {
    var filter: ResultsFilter { get set }
    var results: [QuizResult] { get }
    var filteredResults: [QuizResult] { get }
    var summary: ResultsSummary? { get }
    var isLoading: Bool { get }
    var error: ResultsError? { get set }

    func loadResults() async
    func openResult(_ result: QuizResult)
    func openFilterOptions()
}

@MainActor
final class ResultsViewModelImpl: ResultsViewModel {

    let coordinator: ResultsCoordinator
    private let resultsRepository: ResultsRepository

    @Published var filter: ResultsFilter = .all
    @Published private(set) var results: [QuizResult] = []
    @Published private(set) var summary: ResultsSummary?
    @Published private(set) var isLoading: Bool = false
    @Published var error: ResultsError?

    var filteredResults: [QuizResult] {
        results.filter { $0.matches(filter) }
    }

    init(
        coordinator: ResultsCoordinator,
        resultsRepository: ResultsRepository = ResultsRepositoryMock()
    ) {
        self.coordinator = coordinator
        self.resultsRepository = resultsRepository
    }

    func loadResults() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            async let fetchedResults = resultsRepository.fetchResults()
            async let fetchedSummary = resultsRepository.fetchSummary()
            results = try await fetchedResults
            summary = try await fetchedSummary
        } catch {
            Logger.shared.log("Failed to load results: \(error)", level: .error)
            self.error = .loadFailed
        }
    }

    func openResult(_ result: QuizResult) {
        coordinator.openResult(result)
    }

    func openFilterOptions() {
        Logger.shared.log("Results filter options tapped", level: .info)
    }
}

final class ResultsPreviewViewModel: ResultsViewModel {
    @Published var filter: ResultsFilter = .all
    @Published private(set) var results: [QuizResult] = ResultsPreviewViewModel.sampleResults
    @Published private(set) var summary: ResultsSummary? = ResultsSummary(
        averageScorePercent: 84,
        quizzesCompleted: 48,
        totalAttempts: 63,
        streakDays: 12
    )
    var filteredResults: [QuizResult] {
        results.filter { $0.matches(filter) }
    }
    var isLoading: Bool = false
    var error: ResultsError?

    func loadResults() async {}
    func openResult(_ result: QuizResult) {}
    func openFilterOptions() {}

    private static let sampleResults: [QuizResult] = {
        let now = Date()
        let calendar = Calendar.current
        return [
            QuizResult(
                id: "1",
                quizTitle: "Swift Basics",
                iconName: "chevron.left.forwardslash.chevron.right",
                iconGlow: .blue,
                completedAt: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                correctCount: 10,
                totalCount: 12,
                durationSeconds: 225,
                xpEarned: 150,
                scorePercent: 82,
                isComposite: false
            ),
            QuizResult(
                id: "2",
                quizTitle: "World History",
                iconName: "globe.americas.fill",
                iconGlow: .blue,
                completedAt: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                correctCount: 18,
                totalCount: 20,
                durationSeconds: 512,
                xpEarned: 220,
                scorePercent: 90,
                isComposite: false
            ),
            QuizResult(
                id: "3",
                quizTitle: "English Grammar",
                iconName: "book.fill",
                iconGlow: .purple,
                completedAt: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                correctCount: 8,
                totalCount: 12,
                durationSeconds: 245,
                xpEarned: 90,
                scorePercent: 67,
                isComposite: false
            )
        ]
    }()
}
