import Foundation

protocol QuizPlayCoordinator {
    func showSessionResult(_ result: QuizPlaySessionResult) async
    func dismiss() async
}

enum QuizPlayError: Error {
    case loadFailed
}

@MainActor
protocol QuizPlayViewModel: ObservableObject {
    var quizTitle: String { get }
    var iconName: String { get }
    var questions: [QuizPlayQuestion] { get }
    var currentIndex: Int { get }
    var selectedOptionIDs: Set<String> { get }
    var elapsedSeconds: Int { get }
    var isLoading: Bool { get }
    var isComplete: Bool { get }
    var sessionResult: QuizPlaySessionResult? { get }
    var error: QuizPlayError? { get set }

    var currentQuestion: QuizPlayQuestion? { get }
    var progressText: String { get }
    var canGoBack: Bool { get }
    var canConfirm: Bool { get }

    func load() async
    func selectOption(_ optionID: String)
    func confirmAnswer()
    func goBack()
    func finishSession()
    func retry()
    func reviewAnswers()
}

@MainActor
final class QuizPlayViewModelImpl: QuizPlayViewModel {
    let coordinator: QuizPlayCoordinator
    private let quizID: String
    private let repository: QuizPlayRepository

    @Published private(set) var quizTitle: String = ""
    @Published private(set) var iconName: String = "questionmark.circle"
    @Published private(set) var questions: [QuizPlayQuestion] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var selectedOptionIDs: Set<String> = []
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isComplete: Bool = false
    @Published private(set) var sessionResult: QuizPlaySessionResult?
    @Published var error: QuizPlayError?

    private var answers: [String: Set<String>] = [:]
    private var timerTask: Task<Void, Never>?

    var currentQuestion: QuizPlayQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var progressText: String {
        guard !questions.isEmpty else { return "0 / 0" }
        return "\(currentIndex + 1) / \(questions.count)"
    }

    var canGoBack: Bool { currentIndex > 0 && !isComplete }
    var canConfirm: Bool { !selectedOptionIDs.isEmpty && !isComplete }

    init(
        quizID: String,
        coordinator: QuizPlayCoordinator,
        repository: QuizPlayRepository = QuizPlayRepositoryMock()
    ) {
        self.quizID = quizID
        self.coordinator = coordinator
        self.repository = repository
    }

    deinit {
        timerTask?.cancel()
    }

    func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let payload = try await repository.loadQuiz(id: quizID)
            quizTitle = payload.title
            iconName = payload.iconName
            questions = payload.questions
            startTimer()
        } catch {
            self.error = .loadFailed
        }
    }

    func selectOption(_ optionID: String) {
        guard let question = currentQuestion else { return }
        switch question.type {
        case .singleChoice:
            selectedOptionIDs = [optionID]
        case .multipleChoice:
            if selectedOptionIDs.contains(optionID) {
                selectedOptionIDs.remove(optionID)
            } else {
                selectedOptionIDs.insert(optionID)
            }
        case .textAnswer:
            selectedOptionIDs = [optionID]
        }
    }

    func confirmAnswer() {
        guard let question = currentQuestion else { return }
        answers[question.id] = selectedOptionIDs
        if currentIndex >= questions.count - 1 {
            finishSession()
            return
        }
        currentIndex += 1
        selectedOptionIDs = answers[questions[currentIndex].id] ?? []
    }

    func goBack() {
        guard canGoBack else { return }
        currentIndex -= 1
        selectedOptionIDs = answers[questions[currentIndex].id] ?? []
    }

    func finishSession() {
        timerTask?.cancel()
        isComplete = true
        let correct = questions.filter { question in
            answers[question.id] == question.correctOptionIDs
        }.count
        let total = questions.count
        let score = total > 0 ? (correct * 100) / total : 0
        sessionResult = QuizPlaySessionResult(
            sessionID: UUID().uuidString,
            quizTitle: quizTitle,
            iconName: iconName,
            correctCount: correct,
            totalCount: total,
            durationSeconds: elapsedSeconds,
            xpEarned: score * 2,
            scorePercent: score,
            coinsEarned: score / 4,
            leveledUp: score >= 80,
            newLevel: score >= 80 ? 19 : nil
        )
    }

    func retry() {
        currentIndex = 0
        selectedOptionIDs = []
        answers = [:]
        isComplete = false
        sessionResult = nil
        elapsedSeconds = 0
        startTimer()
    }

    func reviewAnswers() {
        guard let sessionResult else { return }
        Task {
            await coordinator.showSessionResult(sessionResult)
        }
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled && !isComplete {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                elapsedSeconds += 1
            }
        }
    }
}
