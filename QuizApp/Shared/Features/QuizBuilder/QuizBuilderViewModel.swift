import Foundation

enum QuizBuilderStep: Int, CaseIterable, Equatable {
    case quizDetails = 0
    case questions = 1
    case preview = 2
    case publish = 3

    var number: Int { rawValue + 1 }

    var next: QuizBuilderStep? {
        QuizBuilderStep(rawValue: rawValue + 1)
    }

    var previous: QuizBuilderStep? {
        QuizBuilderStep(rawValue: rawValue - 1)
    }
}

enum QuizCoverOption: String, CaseIterable, Identifiable, Equatable {
    case graduationCap
    case globe
    case book
    case microscope

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .graduationCap: return "graduationcap.fill"
        case .globe: return "globe.americas.fill"
        case .book: return "book.fill"
        case .microscope: return "microscope"
        }
    }

    var usesOrangeAccent: Bool {
        switch self {
        case .graduationCap, .book: return true
        case .globe, .microscope: return false
        }
    }
}

enum QuizCategoryOption: String, CaseIterable, Identifiable, Equatable {
    case education
    case science
    case history
    case languages
    case other

    var id: String { rawValue }
}

enum QuizLanguageOption: String, CaseIterable, Identifiable, Equatable {
    case english
    case ukrainian
    case spanish
    case german

    var id: String { rawValue }
}

@MainActor
protocol QuizBuilderViewModel: ObservableObject {
    var currentStep: QuizBuilderStep { get }
    var title: String { get set }
    var descriptionText: String { get set }
    var selectedCover: QuizCoverOption { get set }
    var category: QuizCategoryOption? { get set }
    var language: QuizLanguageOption { get set }
    var questions: [QuizBuilderQuestion] { get }
    var questionEditor: QuizBuilderQuestionEditorState? { get set }
    var canGoNext: Bool { get }
    var titleCharacterCount: Int { get }
    var descriptionCharacterCount: Int { get }

    func goNext()
    func goBack()
    func selectCover(_ cover: QuizCoverOption)
    func tapMoreCovers()

    func addQuestion()
    func editQuestion(_ question: QuizBuilderQuestion)
    func duplicateQuestion(_ question: QuizBuilderQuestion)
    func deleteQuestion(_ question: QuizBuilderQuestion)
    func deleteAllQuestions()
    func moveQuestions(from source: IndexSet, to destination: Int)
    func updateEditorDraft(_ draft: QuizBuilderQuestion)
    func saveQuestionEditor()
    func cancelQuestionEditor()
}

enum QuizBuilderLimits {
    static let titleMaxLength = 100
    static let descriptionMaxLength = 300
}

@MainActor
final class QuizBuilderViewModelImpl: QuizBuilderViewModel {

    let coordinator: QuizBuilderCoordinator

    @Published private(set) var currentStep: QuizBuilderStep = .quizDetails
    @Published var title: String = "" {
        didSet {
            // Do not use inout (`clamp(&title)`) here — write-back re-enters didSet and overflows the stack.
            if title.count > QuizBuilderLimits.titleMaxLength {
                title = String(title.prefix(QuizBuilderLimits.titleMaxLength))
            }
        }
    }
    @Published var descriptionText: String = "" {
        didSet {
            if descriptionText.count > QuizBuilderLimits.descriptionMaxLength {
                descriptionText = String(descriptionText.prefix(QuizBuilderLimits.descriptionMaxLength))
            }
        }
    }
    @Published var selectedCover: QuizCoverOption = .graduationCap
    @Published var category: QuizCategoryOption? = .education
    @Published var language: QuizLanguageOption = .english
    @Published private(set) var questions: [QuizBuilderQuestion] = []
    @Published var questionEditor: QuizBuilderQuestionEditorState?

    var titleCharacterCount: Int { title.count }
    var descriptionCharacterCount: Int { descriptionText.count }

    var canGoNext: Bool {
        switch currentStep {
        case .quizDetails:
            return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .questions:
            return !questions.isEmpty && questions.allSatisfy(\.isValid)
        case .preview, .publish:
            return true
        }
    }

    init(coordinator: QuizBuilderCoordinator) {
        self.coordinator = coordinator
    }

    func goNext() {
        guard canGoNext else { return }
        guard currentStep != .publish, let next = currentStep.next else { return }
        currentStep = next
    }

    func goBack() {
        if let previous = currentStep.previous {
            currentStep = previous
            return
        }
        Task {
            await coordinator.dismiss()
        }
    }

    func selectCover(_ cover: QuizCoverOption) {
        selectedCover = cover
    }

    func tapMoreCovers() {
        // Reserved for expanded cover picker.
    }

    func addQuestion() {
        questionEditor = QuizBuilderQuestionEditorState(
            draft: QuizBuilderQuestion(),
            isNew: true
        )
    }

    func editQuestion(_ question: QuizBuilderQuestion) {
        questionEditor = QuizBuilderQuestionEditorState(
            draft: question,
            isNew: false
        )
    }

    func duplicateQuestion(_ question: QuizBuilderQuestion) {
        questions.append(question.duplicated())
    }

    func deleteQuestion(_ question: QuizBuilderQuestion) {
        questions.removeAll { $0.id == question.id }
    }

    func deleteAllQuestions() {
        questions.removeAll()
    }

    func moveQuestions(from source: IndexSet, to destination: Int) {
        questions.move(fromOffsets: source, toOffset: destination)
    }

    func updateEditorDraft(_ draft: QuizBuilderQuestion) {
        guard var editor = questionEditor else { return }
        editor.draft = sanitize(draft)
        questionEditor = editor
    }

    func saveQuestionEditor() {
        guard let editor = questionEditor, editor.draft.isValid else { return }
        let draft = sanitize(editor.draft)

        if editor.isNew {
            questions.append(draft)
        } else if let index = questions.firstIndex(where: { $0.id == draft.id }) {
            questions[index] = draft
        }

        questionEditor = nil
    }

    func cancelQuestionEditor() {
        questionEditor = nil
    }

    private func sanitize(_ question: QuizBuilderQuestion) -> QuizBuilderQuestion {
        var result = question
        clamp(&result.prompt, maxLength: QuizBuilderQuestionLimits.promptMaxLength)
        clamp(&result.acceptedTextAnswer, maxLength: QuizBuilderQuestionLimits.textAnswerMaxLength)
        result.options = result.options.map { option in
            var updated = option
            clamp(&updated.text, maxLength: QuizBuilderQuestionLimits.optionMaxLength)
            return updated
        }
        return result
    }

    private func clamp(_ value: inout String, maxLength: Int) {
        guard value.count > maxLength else { return }
        value = String(value.prefix(maxLength))
    }
}
