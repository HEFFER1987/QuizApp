import Foundation

enum ResultsRepositoryError: Error {
    case loadFailed
    case notFound
}

protocol ResultsRepository {
    func fetchResults() async throws -> [QuizResult]
    func fetchSummary() async throws -> ResultsSummary
    func fetchResultDetail(id: String) async throws -> QuizResultDetail
}

struct ResultsRepositoryMock: ResultsRepository {
    func fetchResults() async throws -> [QuizResult] {
        Self.sampleResults
    }

    func fetchSummary() async throws -> ResultsSummary {
        ResultsSummary(
            averageScorePercent: 84,
            quizzesCompleted: 48,
            totalAttempts: 63,
            streakDays: 12,
            globalRank: 14
        )
    }

    func fetchResultDetail(id: String) async throws -> QuizResultDetail {
        if id == "1" {
            return Self.swiftBasicsDetail
        }

        guard let result = Self.sampleResults.first(where: { $0.id == id }) else {
            throw ResultsRepositoryError.notFound
        }

        return Self.makeGenericDetail(from: result)
    }

    private static let sampleResults: [QuizResult] = {
        let now = Date()
        let calendar = Calendar.current

        func date(daysAgo: Int, hour: Int, minute: Int) -> Date {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = minute
            let base = calendar.date(from: components) ?? now
            return calendar.date(byAdding: .day, value: -daysAgo, to: base) ?? now
        }

        return [
            QuizResult(
                id: "1",
                quizTitle: "Swift Basics",
                iconName: "chevron.left.forwardslash.chevron.right",
                iconGlow: .blue,
                completedAt: date(daysAgo: 1, hour: 18, minute: 30),
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
                completedAt: date(daysAgo: 2, hour: 14, minute: 10),
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
                completedAt: date(daysAgo: 3, hour: 20, minute: 5),
                correctCount: 8,
                totalCount: 12,
                durationSeconds: 245,
                xpEarned: 90,
                scorePercent: 67,
                isComposite: false
            ),
            QuizResult(
                id: "4",
                quizTitle: "Swift Advanced",
                iconName: "chevron.left.forwardslash.chevron.right",
                iconGlow: .orange,
                completedAt: date(daysAgo: 5, hour: 11, minute: 40),
                correctCount: 20,
                totalCount: 20,
                durationSeconds: 380,
                xpEarned: 300,
                scorePercent: 100,
                isComposite: false
            ),
            QuizResult(
                id: "5",
                quizTitle: "Mixed Challenge",
                iconName: "square.stack.3d.up.fill",
                iconGlow: .green,
                completedAt: date(daysAgo: 6, hour: 16, minute: 0),
                correctCount: 14,
                totalCount: 18,
                durationSeconds: 410,
                xpEarned: 180,
                scorePercent: 78,
                isComposite: true
            ),
            QuizResult(
                id: "6",
                quizTitle: "Literature Classics",
                iconName: "text.book.closed.fill",
                iconGlow: .purple,
                completedAt: date(daysAgo: 7, hour: 19, minute: 25),
                correctCount: 9,
                totalCount: 10,
                durationSeconds: 198,
                xpEarned: 160,
                scorePercent: 90,
                isComposite: false
            )
        ]
    }()

    private static var swiftBasicsDetail: QuizResultDetail {
        let result = sampleResults[0]
        return QuizResultDetail(
            result: result,
            difficulty: .medium,
            questions: [
                ResultQuestionReview(
                    id: "1-q1",
                    number: 1,
                    prompt: "Что выведет следующий код?",
                    codeSnippet: "let x = 5\nprint(x * 2)",
                    userAnswer: "10",
                    correctAnswer: "10",
                    isCorrect: true,
                    explanation: "Переменная x равна 5, при умножении на 2 получаем 10.",
                    options: nil
                ),
                ResultQuestionReview(
                    id: "1-q2",
                    number: 2,
                    prompt: "Какой тип у значения \"Hello\"?",
                    codeSnippet: nil,
                    userAnswer: "String",
                    correctAnswer: "String",
                    isCorrect: true,
                    explanation: "Строковые литералы в Swift имеют тип String.",
                    options: nil
                ),
                ResultQuestionReview(
                    id: "1-q3",
                    number: 3,
                    prompt: "Какой модификатор доступа ограничивает видимость файлом?",
                    codeSnippet: nil,
                    userAnswer: "private",
                    correctAnswer: "fileprivate",
                    isCorrect: false,
                    explanation: "fileprivate ограничивает доступ текущим файлом. private — объявлением.",
                    options: nil
                ),
                ResultQuestionReview(
                    id: "1-q4",
                    number: 4,
                    prompt: "Какой протокол используется для сравнения на равенство?",
                    codeSnippet: nil,
                    userAnswer: "Comparable",
                    correctAnswer: "Equatable",
                    isCorrect: false,
                    explanation: "Equatable описывает равенство (==). Comparable добавляет упорядочивание (<, >).",
                    options: [
                        ResultAnswerOption(id: "1-q4-a", text: "Equatable", state: .correctOnly),
                        ResultAnswerOption(id: "1-q4-b", text: "Comparable", state: .userWrong),
                        ResultAnswerOption(id: "1-q4-c", text: "Hashable", state: .neutral),
                        ResultAnswerOption(id: "1-q4-d", text: "Codable", state: .neutral)
                    ]
                ),
                ResultQuestionReview(
                    id: "1-q5",
                    number: 5,
                    prompt: "Что означает ключевое слово let?",
                    codeSnippet: nil,
                    userAnswer: "Неизменяемая константа",
                    correctAnswer: "Неизменяемая константа",
                    isCorrect: true,
                    explanation: "let объявляет константу, значение которой нельзя переназначить.",
                    options: nil
                ),
                ResultQuestionReview(
                    id: "1-q6",
                    number: 6,
                    prompt: "Какой результат у выражения?",
                    codeSnippet: "let a = [1, 2, 3]\nprint(a.count)",
                    userAnswer: "3",
                    correctAnswer: "3",
                    isCorrect: true,
                    explanation: "Массив содержит три элемента, поэтому count равен 3.",
                    options: nil
                )
            ]
        )
    }

    private static func makeGenericDetail(from result: QuizResult) -> QuizResultDetail {
        let incorrectCount = max(result.totalCount - result.correctCount, 0)
        let incorrectIndices = Set(0..<incorrectCount)

        let questions = (1...result.totalCount).map { number in
            let isCorrect = !incorrectIndices.contains(number - 1)
            return ResultQuestionReview(
                id: "\(result.id)-q\(number)",
                number: number,
                prompt: "Question \(number)",
                codeSnippet: nil,
                userAnswer: isCorrect ? "Correct option" : "Wrong option",
                correctAnswer: "Correct option",
                isCorrect: isCorrect,
                explanation: isCorrect
                    ? "Your answer matches the expected result."
                    : "Review this topic and try again on the next attempt.",
                options: nil
            )
        }

        let difficulty: QuizDifficulty
        switch result.scorePercent {
        case 90...:
            difficulty = .easy
        case 70..<90:
            difficulty = .medium
        default:
            difficulty = .hard
        }

        return QuizResultDetail(
            result: result,
            difficulty: difficulty,
            questions: questions
        )
    }
}

struct ResultsRepositoryLive: ResultsRepository {
    private let fallback = ResultsRepositoryMock()

    func fetchResults() async throws -> [QuizResult] {
        try await fallback.fetchResults()
    }

    func fetchSummary() async throws -> ResultsSummary {
        try await fallback.fetchSummary()
    }

    func fetchResultDetail(id: String) async throws -> QuizResultDetail {
        try await fallback.fetchResultDetail(id: id)
    }
}
