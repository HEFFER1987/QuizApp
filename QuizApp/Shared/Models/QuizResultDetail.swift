import Foundation

enum QuizDifficulty: String, Equatable, CaseIterable {
    case easy
    case medium
    case hard
}

enum ResultQuestionFilter: Equatable, CaseIterable {
    case all
    case errorsOnly
}

enum ResultAnswerOptionState: Equatable {
    case neutral
    case userCorrect
    case userWrong
    case correctOnly
}

struct ResultAnswerOption: Identifiable, Equatable {
    let id: String
    let text: String
    let state: ResultAnswerOptionState
}

struct ResultQuestionReview: Identifiable, Equatable {
    let id: String
    let number: Int
    let prompt: String
    let codeSnippet: String?
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
    let explanation: String
    let options: [ResultAnswerOption]?
}

struct QuizResultDetail: Identifiable, Equatable {
    let result: QuizResult
    let difficulty: QuizDifficulty
    let questions: [ResultQuestionReview]

    var id: String { result.id }

    var errorCount: Int {
        questions.filter { !$0.isCorrect }.count
    }
}
