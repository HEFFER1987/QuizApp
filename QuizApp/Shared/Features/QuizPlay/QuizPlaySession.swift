import Foundation

struct QuizPlayQuestion: Identifiable, Equatable {
    let id: String
    let prompt: String
    let options: [QuizPlayOption]
    let type: QuizBuilderQuestionType
    let correctOptionIDs: Set<String>
    let categoryLabel: String?
    let codeSnippet: String?
    let explanation: String

    init(
        id: String,
        prompt: String,
        options: [QuizPlayOption],
        type: QuizBuilderQuestionType,
        correctOptionIDs: Set<String>,
        categoryLabel: String? = nil,
        codeSnippet: String? = nil,
        explanation: String = ""
    ) {
        self.id = id
        self.prompt = prompt
        self.options = options
        self.type = type
        self.correctOptionIDs = correctOptionIDs
        self.categoryLabel = categoryLabel
        self.codeSnippet = codeSnippet
        self.explanation = explanation
    }
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

    private static let mapCodeSnippet = """
        let array = [1, 2, 3]
        let result = array.map { $0 * 2 }
        print(result)
        """

    private static let sampleQuestions: [QuizPlayQuestion] = [
        QuizPlayQuestion(
            id: "1",
            prompt: "What is Swift?",
            options: [
                QuizPlayOption(id: "1a", text: "A programming language"),
                QuizPlayOption(id: "1b", text: "A bird species"),
                QuizPlayOption(id: "1c", text: "A database"),
                QuizPlayOption(id: "1d", text: "An IDE")
            ],
            type: .singleChoice,
            correctOptionIDs: ["1a"],
            categoryLabel: "Swift Basics",
            explanation: "Правильный ответ: B\n[1, 2, 3] * 2 = [2, 4, 6]"
        ),
        QuizPlayQuestion(
            id: "2",
            prompt: "Which keyword declares a constant?",
            options: [
                QuizPlayOption(id: "2a", text: "var"),
                QuizPlayOption(id: "2b", text: "let"),
                QuizPlayOption(id: "2c", text: "const"),
                QuizPlayOption(id: "2d", text: "final")
            ],
            type: .singleChoice,
            correctOptionIDs: ["2b"],
            categoryLabel: "Swift Basics"
        ),
        QuizPlayQuestion(
            id: "3",
            prompt: "What does optional chaining use?",
            options: [
                QuizPlayOption(id: "3a", text: "?."),
                QuizPlayOption(id: "3b", text: "!!"),
                QuizPlayOption(id: "3c", text: "::"),
                QuizPlayOption(id: "3d", text: "->")
            ],
            type: .singleChoice,
            correctOptionIDs: ["3a"],
            categoryLabel: "Swift Basics"
        ),
        QuizPlayQuestion(
            id: "4",
            prompt: "What is the result of the following code?",
            options: [
                QuizPlayOption(id: "4a", text: "[1, 2, 3]"),
                QuizPlayOption(id: "4b", text: "[2, 4, 6]"),
                QuizPlayOption(id: "4c", text: "[3, 6, 9]"),
                QuizPlayOption(id: "4d", text: "Compilation error")
            ],
            type: .singleChoice,
            correctOptionIDs: ["4b"],
            categoryLabel: "Swift Basics",
            codeSnippet: mapCodeSnippet,
            explanation: "Correct answer: B — map doubles each element to [2, 4, 6]."
        ),
        QuizPlayQuestion(
            id: "5",
            prompt: "Which are value types in Swift?",
            options: [
                QuizPlayOption(id: "5a", text: "struct"),
                QuizPlayOption(id: "5b", text: "class"),
                QuizPlayOption(id: "5c", text: "enum"),
                QuizPlayOption(id: "5d", text: "actor")
            ],
            type: .multipleChoice,
            correctOptionIDs: ["5a", "5c"],
            categoryLabel: "Types",
            explanation: "struct и enum — value types; class и actor — reference types."
        ),
        QuizPlayQuestion(
            id: "6",
            prompt: "What is the type of `nil` in Swift?",
            options: [
                QuizPlayOption(id: "6a", text: "Optional"),
                QuizPlayOption(id: "6b", text: "Void"),
                QuizPlayOption(id: "6c", text: "Any"),
                QuizPlayOption(id: "6d", text: "Never")
            ],
            type: .singleChoice,
            correctOptionIDs: ["6a"],
            categoryLabel: "Optionals"
        ),
        QuizPlayQuestion(
            id: "7",
            prompt: "Which protocol is used for equality?",
            options: [
                QuizPlayOption(id: "7a", text: "Equatable"),
                QuizPlayOption(id: "7b", text: "Comparable"),
                QuizPlayOption(id: "7c", text: "Hashable"),
                QuizPlayOption(id: "7d", text: "Identifiable")
            ],
            type: .singleChoice,
            correctOptionIDs: ["7a"],
            categoryLabel: "Protocols"
        ),
        QuizPlayQuestion(
            id: "8",
            prompt: "Select all collection types in Swift standard library.",
            options: [
                QuizPlayOption(id: "8a", text: "Array"),
                QuizPlayOption(id: "8b", text: "Dictionary"),
                QuizPlayOption(id: "8c", text: "Set"),
                QuizPlayOption(id: "8d", text: "Graph")
            ],
            type: .multipleChoice,
            correctOptionIDs: ["8a", "8b", "8c"],
            categoryLabel: "Collections"
        ),
        QuizPlayQuestion(
            id: "9",
            prompt: "What does `guard` typically do?",
            options: [
                QuizPlayOption(id: "9a", text: "Early exit if a condition fails"),
                QuizPlayOption(id: "9b", text: "Locks a mutex"),
                QuizPlayOption(id: "9c", text: "Declares a class"),
                QuizPlayOption(id: "9d", text: "Imports a module")
            ],
            type: .singleChoice,
            correctOptionIDs: ["9a"],
            categoryLabel: "Control Flow"
        ),
        QuizPlayQuestion(
            id: "10",
            prompt: "Which access level is the most restrictive?",
            options: [
                QuizPlayOption(id: "10a", text: "private"),
                QuizPlayOption(id: "10b", text: "fileprivate"),
                QuizPlayOption(id: "10c", text: "internal"),
                QuizPlayOption(id: "10d", text: "public")
            ],
            type: .singleChoice,
            correctOptionIDs: ["10a"],
            categoryLabel: "Access Control"
        ),
        QuizPlayQuestion(
            id: "11",
            prompt: "Name the Swift construct for structured concurrency.",
            options: [
                QuizPlayOption(id: "11a", text: "async/await"),
                QuizPlayOption(id: "11b", text: "goto"),
                QuizPlayOption(id: "11c", text: "coroutine macro only"),
                QuizPlayOption(id: "11d", text: "pthread")
            ],
            type: .singleChoice,
            correctOptionIDs: ["11a"],
            categoryLabel: "Concurrency"
        ),
        QuizPlayQuestion(
            id: "12",
            prompt: "What is `@MainActor` used for?",
            options: [
                QuizPlayOption(id: "12a", text: "UI-isolated code on the main thread"),
                QuizPlayOption(id: "12b", text: "Network requests only"),
                QuizPlayOption(id: "12c", text: "Disk encryption"),
                QuizPlayOption(id: "12d", text: "Unit tests")
            ],
            type: .singleChoice,
            correctOptionIDs: ["12a"],
            categoryLabel: "Concurrency"
        )
    ]
}

struct QuizPlayRepositoryLive: QuizPlayRepository {
    private let fallback = QuizPlayRepositoryMock()

    func loadQuiz(id: String) async throws -> (title: String, iconName: String, questions: [QuizPlayQuestion]) {
        try await fallback.loadQuiz(id: id)
    }
}
