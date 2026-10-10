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

    var editorQuestionIndex: Int { get }
    var editorQuestionTotal: Int { get }

    func addQuestion()
    func editQuestion(_ question: QuizBuilderQuestion)
    func duplicateQuestion(_ question: QuizBuilderQuestion)
    func deleteQuestion(_ question: QuizBuilderQuestion)
    func deleteAllQuestions()
    func moveQuestions(from source: IndexSet, to destination: Int)
    func updateEditorDraft(_ draft: QuizBuilderQuestion)
    func saveQuestionEditor()
    func cancelQuestionEditor()
    func deleteQuestionFromEditor()

    var previewQuestionIndex: Int { get }
    var currentPreviewQuestion: QuizBuilderQuestion? { get }
    var isOnLastPreviewQuestion: Bool { get }
    var previewEstimatedMinutes: Int { get }
    var sharePreviewText: String { get }
    var isCurrentPreviewQuestionBookmarked: Bool { get }

    func selectPreviewOption(_ optionID: UUID)
    func isPreviewOptionSelected(_ optionID: UUID) -> Bool
    func togglePreviewBookmark()
    func goToPreviewQuestion(at index: Int)
    func previewGoNext()
    func previewGoBack()

    var difficulty: String { get set }
    var tagsText: String { get set }
    var selectedQuestionID: UUID? { get set }
    var selectedQuestion: QuizBuilderQuestion? { get }

    func selectQuestion(_ question: QuizBuilderQuestion?)
    func ensureSelectionAfterChanges()
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
    @Published var difficulty: String = "Medium"
    @Published var tagsText: String = ""
    @Published private(set) var questions: [QuizBuilderQuestion] = []
    @Published var questionEditor: QuizBuilderQuestionEditorState?
    @Published var selectedQuestionID: UUID?
    @Published private(set) var previewQuestionIndex: Int = 0
    @Published private var previewSelectedOptionIDs: [UUID: Set<UUID>] = [:]
    @Published private var previewBookmarkedQuestionIDs: Set<UUID> = []

    var titleCharacterCount: Int { title.count }
    var descriptionCharacterCount: Int { descriptionText.count }

    var editorQuestionIndex: Int {
        guard let draftID = questionEditor?.draft.id,
              let index = questions.firstIndex(where: { $0.id == draftID }) else {
            return max(questions.count, 1)
        }
        return index + 1
    }

    var editorQuestionTotal: Int {
        max(questions.count, 1)
    }

    var currentPreviewQuestion: QuizBuilderQuestion? {
        guard questions.indices.contains(previewQuestionIndex) else { return nil }
        return questions[previewQuestionIndex]
    }

    var isOnLastPreviewQuestion: Bool {
        guard !questions.isEmpty else { return true }
        return previewQuestionIndex >= questions.count - 1
    }

    var previewEstimatedMinutes: Int {
        max(1, (questions.count + 1) / 2)
    }

    var sharePreviewText: String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedDescription.isEmpty {
            return trimmedTitle
        }
        return "\(trimmedTitle)\n\(trimmedDescription)"
    }

    var isCurrentPreviewQuestionBookmarked: Bool {
        guard let questionID = currentPreviewQuestion?.id else { return false }
        return previewBookmarkedQuestionIDs.contains(questionID)
    }

    var selectedQuestion: QuizBuilderQuestion? {
        guard let selectedQuestionID else { return nil }
        return questions.first { $0.id == selectedQuestionID }
    }

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
        if next == .publish, !AppStateManager.shared.canPublishContent {
            return
        }
        if next == .preview {
            resetPreviewSession()
        }
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
        let draft = QuizBuilderQuestion()
        questions.append(draft)
        selectQuestion(draft)
        questionEditor = QuizBuilderQuestionEditorState(
            draft: draft,
            isNew: true
        )
    }

    func editQuestion(_ question: QuizBuilderQuestion) {
        selectQuestion(question)
        questionEditor = QuizBuilderQuestionEditorState(
            draft: question,
            isNew: false
        )
    }

    func selectQuestion(_ question: QuizBuilderQuestion?) {
        selectedQuestionID = question?.id
    }

    func ensureSelectionAfterChanges() {
        if let selectedQuestionID,
           questions.contains(where: { $0.id == selectedQuestionID }) {
            return
        }
        selectedQuestionID = questions.first?.id
    }

    func duplicateQuestion(_ question: QuizBuilderQuestion) {
        questions.append(question.duplicated())
    }

    func deleteQuestion(_ question: QuizBuilderQuestion) {
        questions.removeAll { $0.id == question.id }
        ensureSelectionAfterChanges()
    }

    func deleteAllQuestions() {
        questions.removeAll()
        selectedQuestionID = nil
    }

    func moveQuestions(from source: IndexSet, to destination: Int) {
        questions.move(fromOffsets: source, toOffset: destination)
    }

    func updateEditorDraft(_ draft: QuizBuilderQuestion) {
        guard var editor = questionEditor else { return }
        let sanitized = sanitize(draft)
        editor.draft = sanitized
        questionEditor = editor
        upsertQuestion(sanitized)
    }

    func saveQuestionEditor() {
        guard let editor = questionEditor, editor.draft.isValid else { return }
        upsertQuestion(sanitize(editor.draft))
        questionEditor = nil
    }

    func cancelQuestionEditor() {
        questionEditor = nil
    }

    func deleteQuestionFromEditor() {
        guard let draftID = questionEditor?.draft.id else { return }
        questions.removeAll { $0.id == draftID }
        questionEditor = nil
    }

    func selectPreviewOption(_ optionID: UUID) {
        guard let question = currentPreviewQuestion else { return }
        var selections = previewSelectedOptionIDs
        var selected = selections[question.id] ?? []
        switch question.type {
        case .singleChoice, .textAnswer:
            selected = [optionID]
        case .multipleChoice:
            if selected.contains(optionID) {
                selected.remove(optionID)
            } else {
                selected.insert(optionID)
            }
        }
        selections[question.id] = selected
        previewSelectedOptionIDs = selections
    }

    func isPreviewOptionSelected(_ optionID: UUID) -> Bool {
        guard let questionID = currentPreviewQuestion?.id else { return false }
        return previewSelectedOptionIDs[questionID]?.contains(optionID) ?? false
    }

    func togglePreviewBookmark() {
        guard let questionID = currentPreviewQuestion?.id else { return }
        var bookmarks = previewBookmarkedQuestionIDs
        if bookmarks.contains(questionID) {
            bookmarks.remove(questionID)
        } else {
            bookmarks.insert(questionID)
        }
        previewBookmarkedQuestionIDs = bookmarks
    }

    func goToPreviewQuestion(at index: Int) {
        guard questions.indices.contains(index) else { return }
        previewQuestionIndex = index
    }

    func previewGoNext() {
        if isOnLastPreviewQuestion {
            goNext()
            return
        }
        goToPreviewQuestion(at: previewQuestionIndex + 1)
    }

    func previewGoBack() {
        goToPreviewQuestion(at: previewQuestionIndex - 1)
    }

    private func resetPreviewSession() {
        previewQuestionIndex = 0
        previewSelectedOptionIDs = [:]
        previewBookmarkedQuestionIDs = []
    }

    private func upsertQuestion(_ question: QuizBuilderQuestion) {
        if let index = questions.firstIndex(where: { $0.id == question.id }) {
            questions[index] = question
        } else {
            questions.append(question)
        }
    }

    private func sanitize(_ question: QuizBuilderQuestion) -> QuizBuilderQuestion {
        var result = question
        clamp(&result.prompt, maxLength: QuizBuilderQuestionLimits.promptMaxLength)
        clamp(&result.explanation, maxLength: QuizBuilderQuestionLimits.explanationMaxLength)
        result.points = min(
            max(result.points, QuizBuilderQuestionLimits.minimumPoints),
            QuizBuilderQuestionLimits.maximumPoints
        )
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
