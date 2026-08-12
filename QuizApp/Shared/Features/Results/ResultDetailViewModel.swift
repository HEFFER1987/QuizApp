import Foundation

enum ResultDetailError: Error {
    case loadFailed
    case notFound
}

@MainActor
protocol ResultDetailViewModel: ObservableObject {
    var detail: QuizResultDetail? { get }
    var isLoading: Bool { get }
    var error: ResultDetailError? { get set }
    var questionFilter: ResultQuestionFilter { get set }
    var expandedExplanationIDs: Set<String> { get }

    var visibleQuestions: [ResultQuestionReview] { get }
    var errorCount: Int { get }
    var shareText: String { get }

    func load() async
    func goBack()
    func retake()
    func toggleExplanation(_ questionID: String)
    func isExplanationExpanded(_ questionID: String) -> Bool
}

@MainActor
final class ResultDetailViewModelImpl: ResultDetailViewModel {

    private let resultId: String
    private let coordinator: ResultDetailCoordinator
    private let resultsRepository: ResultsRepository

    @Published private(set) var detail: QuizResultDetail?
    @Published private(set) var isLoading: Bool = false
    @Published var error: ResultDetailError?
    @Published var questionFilter: ResultQuestionFilter = .all
    @Published private(set) var expandedExplanationIDs: Set<String> = []

    var visibleQuestions: [ResultQuestionReview] {
        guard let detail else { return [] }
        switch questionFilter {
        case .all:
            return detail.questions
        case .errorsOnly:
            return detail.questions.filter { !$0.isCorrect }
        }
    }

    var errorCount: Int {
        detail?.errorCount ?? 0
    }

    var shareText: String {
        guard let detail else { return "" }
        let result = detail.result
        return Strings.ResultsDetail.shareText(
            result.quizTitle,
            result.scorePercent,
            result.correctCount,
            result.totalCount,
            result.xpEarned
        )
    }

    init(
        resultId: String,
        coordinator: ResultDetailCoordinator,
        resultsRepository: ResultsRepository = ResultsRepositoryMock()
    ) {
        self.resultId = resultId
        self.coordinator = coordinator
        self.resultsRepository = resultsRepository
    }

    func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let fetched = try await resultsRepository.fetchResultDetail(id: resultId)
            detail = fetched
            expandedExplanationIDs = Set(
                fetched.questions
                    .filter { !$0.isCorrect && !$0.explanation.isEmpty }
                    .prefix(1)
                    .map(\.id)
            )
        } catch ResultsRepositoryError.notFound {
            Logger.shared.log("Result detail not found: \(resultId)", level: .error)
            error = .notFound
        } catch {
            Logger.shared.log("Failed to load result detail: \(error)", level: .error)
            self.error = .loadFailed
        }
    }

    func goBack() {
        Task {
            await coordinator.dismiss()
        }
    }

    func retake() {
        let title = detail?.result.quizTitle ?? resultId
        Task {
            await coordinator.retakeQuiz(title: title)
        }
    }

    func toggleExplanation(_ questionID: String) {
        if expandedExplanationIDs.contains(questionID) {
            expandedExplanationIDs.remove(questionID)
        } else {
            expandedExplanationIDs.insert(questionID)
        }
    }

    func isExplanationExpanded(_ questionID: String) -> Bool {
        expandedExplanationIDs.contains(questionID)
    }
}

@MainActor
final class ResultDetailPreviewViewModel: ResultDetailViewModel {
    @Published private(set) var detail: QuizResultDetail?
    @Published private(set) var isLoading: Bool = false
    @Published var error: ResultDetailError?
    @Published var questionFilter: ResultQuestionFilter = .all
    @Published private(set) var expandedExplanationIDs: Set<String> = []

    var visibleQuestions: [ResultQuestionReview] {
        guard let detail else { return [] }
        switch questionFilter {
        case .all:
            return detail.questions
        case .errorsOnly:
            return detail.questions.filter { !$0.isCorrect }
        }
    }

    var errorCount: Int {
        detail?.errorCount ?? 0
    }

    var shareText: String {
        guard let detail else { return "Swift Basics" }
        let result = detail.result
        return Strings.ResultsDetail.shareText(
            result.quizTitle,
            result.scorePercent,
            result.correctCount,
            result.totalCount,
            result.xpEarned
        )
    }

    init() {
        Task {
            await load()
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            detail = try await ResultsRepositoryMock().fetchResultDetail(id: "1")
            if let firstError = detail?.questions.first(where: { !$0.isCorrect }) {
                expandedExplanationIDs = [firstError.id]
            }
        } catch {
            self.error = .loadFailed
        }
    }

    func goBack() {}
    func retake() {}

    func toggleExplanation(_ questionID: String) {
        if expandedExplanationIDs.contains(questionID) {
            expandedExplanationIDs.remove(questionID)
        } else {
            expandedExplanationIDs.insert(questionID)
        }
    }

    func isExplanationExpanded(_ questionID: String) -> Bool {
        expandedExplanationIDs.contains(questionID)
    }
}
