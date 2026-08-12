import Foundation
import SwiftUI

enum QuizBuilderQuestionType: String, CaseIterable, Identifiable, Equatable {
    case singleChoice
    case multipleChoice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .singleChoice: return Strings.QuizBuilder.QuestionType.singleChoice
        case .multipleChoice: return Strings.QuizBuilder.QuestionType.multipleChoice
        }
    }

    var systemImage: String {
        switch self {
        case .singleChoice: return "circle.inset.filled"
        case .multipleChoice: return "checkmark.square.fill"
        }
    }

    var usesOrangeAccent: Bool {
        switch self {
        case .singleChoice: return true
        case .multipleChoice: return false
        }
    }

    var accentColor: Color {
        usesOrangeAccent ? QuizTheme.draftGlow : QuizTheme.publishedGlow
    }
}

struct QuizBuilderAnswerOption: Identifiable, Equatable, Hashable {
    let id: UUID
    var text: String
    var isCorrect: Bool

    init(
        id: UUID = UUID(),
        text: String = "",
        isCorrect: Bool = false
    ) {
        self.id = id
        self.text = text
        self.isCorrect = isCorrect
    }

    func duplicated() -> QuizBuilderAnswerOption {
        QuizBuilderAnswerOption(text: text, isCorrect: isCorrect)
    }
}

struct QuizBuilderQuestion: Identifiable, Equatable, Hashable {
    let id: UUID
    var prompt: String
    var type: QuizBuilderQuestionType
    var options: [QuizBuilderAnswerOption]
    var explanation: String
    var points: Int
    var shuffleAnswers: Bool

    init(
        id: UUID = UUID(),
        prompt: String = "",
        type: QuizBuilderQuestionType = .singleChoice,
        options: [QuizBuilderAnswerOption] = [
            QuizBuilderAnswerOption(),
            QuizBuilderAnswerOption()
        ],
        explanation: String = "",
        points: Int = QuizBuilderQuestionLimits.minimumPoints,
        shuffleAnswers: Bool = true
    ) {
        self.id = id
        self.prompt = prompt
        self.type = type
        self.options = options
        self.explanation = explanation
        self.points = points
        self.shuffleAnswers = shuffleAnswers
    }

    var isValid: Bool {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else { return false }

        let filled = options.filter {
            !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        guard filled.count >= QuizBuilderQuestionLimits.minimumOptions else { return false }

        switch type {
        case .singleChoice:
            return filled.filter(\.isCorrect).count == 1
        case .multipleChoice:
            return filled.contains(where: \.isCorrect)
        }
    }

    func duplicated() -> QuizBuilderQuestion {
        QuizBuilderQuestion(
            prompt: prompt,
            type: type,
            options: options.map { $0.duplicated() },
            explanation: explanation,
            points: points,
            shuffleAnswers: shuffleAnswers
        )
    }
}

struct QuizBuilderQuestionEditorState: Identifiable, Equatable {
    var id: UUID { draft.id }
    var draft: QuizBuilderQuestion
    let isNew: Bool
}

enum QuizBuilderQuestionLimits {
    static let promptMaxLength = 300
    static let optionMaxLength = 120
    static let explanationMaxLength = 500
    static let minimumOptions = 2
    static let maximumOptions = 6
    static let minimumPoints = 1
    static let maximumPoints = 10
}
