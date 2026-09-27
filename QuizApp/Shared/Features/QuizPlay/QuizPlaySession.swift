import Foundation

struct QuizPlayQuestion: Identifiable, Equatable {
    let id: String
    let prompt: String
    let options: [QuizPlayOption]
    let type: QuizBuilderQuestionType
    let correctOptionIDs: Set<String>
}

struct QuizPlayOption: Identifiable, Equatable {
    let id: String
    let text: String
}

struct QuizPlaySessionResult: Equatable {
    let sessionID: String
    let quizTitle: String
    let iconName: String
    let correctCount: Int
    let totalCount: Int
    let durationSeconds: Int
    let xpEarned: Int
    let scorePercent: Int
    let coinsEarned: Int
    let leveledUp: Bool
    let newLevel: Int?
}

enum QuizPlayRepositoryError: Error {
    case notFound
}

protocol QuizPlayRepository {
    func loadQuiz(id: String) async throws -> (title: String, iconName: String, questions: [QuizPlayQuestion])
}

struct QuizPlayRepositoryMock: QuizPlayRepository {
    func loadQuiz(id: String) async throws -> (title: String, iconName: String, questions: [QuizPlayQuestion]) {
        (
            title: "Swift Basics",
            iconName: "chevron.left.forwardslash.chevron.right",
            questions: Self.sampleQuestions
        )
    }

    private static let sampleQuestions: [QuizPlayQuestion] = [
        QuizPlayQuestion(
            id: "1",
            prompt: "What is the past tense of \"go\"?",
            options: [
                QuizPlayOption(id: "a", text: "went"),
                QuizPlayOption(id: "b", text: "gone"),
                QuizPlayOption(id: "c", text: "go"),
                QuizPlayOption(id: "d", text: "goed")
            ],
            type: .singleChoice,
            correctOptionIDs: ["a"]
        ),
        QuizPlayQuestion(
            id: "2",
            prompt: "Which are value types in Swift?",
            options: [
                QuizPlayOption(id: "a", text: "struct"),
                QuizPlayOption(id: "b", text: "class"),
                QuizPlayOption(id: "c", text: "enum"),
                QuizPlayOption(id: "d", text: "actor")
            ],
            type: .multipleChoice,
            correctOptionIDs: ["a", "c"]
        )
    ]
}

struct QuizPlayRepositoryLive: QuizPlayRepository {
    private let fallback = QuizPlayRepositoryMock()

    func loadQuiz(id: String) async throws -> (title: String, iconName: String, questions: [QuizPlayQuestion]) {
        try await fallback.loadQuiz(id: id)
    }
}
