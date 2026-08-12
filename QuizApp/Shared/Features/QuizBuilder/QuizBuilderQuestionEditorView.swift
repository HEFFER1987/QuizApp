import SwiftUI

struct QuizBuilderQuestionEditorView<ViewModel: QuizBuilderViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    private var draft: QuizBuilderQuestion {
        viewModel.questionEditor?.draft ?? QuizBuilderQuestion()
    }

    private var isNew: Bool {
        viewModel.questionEditor?.isNew ?? true
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QuizListBackgroundView()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        promptSection
                        typeSection
                        if draft.type == .textAnswer {
                            textAnswerSection
                        } else {
                            optionsSection
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle(
                isNew
                    ? Strings.QuizBuilder.Editor.addTitle
                    : Strings.QuizBuilder.Editor.editTitle
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.QuizBuilder.Action.cancel) {
                        viewModel.cancelQuestionEditor()
                    }
                    .foregroundStyle(QuizTheme.draftGlow)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.QuizBuilder.Action.save) {
                        viewModel.saveQuestionEditor()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(draft.isValid ? QuizTheme.draftGlow : QuizTheme.mutedText)
                    .disabled(!draft.isValid)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            QuizBuilderEditorSectionLabel(
                icon: "text.bubble.fill",
                text: Strings.QuizBuilder.Editor.prompt
            )
            QuizBuilderOutlinedField(minHeight: 96) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: promptBinding)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .tint(QuizTheme.draftGlow)
                        .frame(minHeight: 76)
                    if draft.prompt.isEmpty {
                        Text(Strings.QuizBuilder.Editor.promptPlaceholder)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(QuizTheme.mutedText.opacity(0.7))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
            }
            QuizBuilderEditorCharacterCount(
                current: draft.prompt.count,
                max: QuizBuilderQuestionLimits.promptMaxLength
            )
        }
        .padding(16)
        .background(QuizBuilderEditorCardBackground())
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            QuizBuilderEditorSectionLabel(
                icon: "slider.horizontal.3",
                text: Strings.QuizBuilder.Editor.type
            )
            HStack(spacing: 8) {
                ForEach(QuizBuilderQuestionType.allCases) { type in
                    QuizBuilderQuestionTypeChip(
                        type: type,
                        isSelected: draft.type == type,
                        onTap: { selectType(type) }
                    )
                }
            }
        }
        .padding(16)
        .background(QuizBuilderEditorCardBackground())
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            QuizBuilderEditorSectionLabel(
                icon: "list.bullet",
                text: Strings.QuizBuilder.Editor.options
            )

            ForEach(Array(draft.options.enumerated()), id: \.element.id) { index, option in
                QuizBuilderOptionEditorRow(
                    correctSymbol: correctSymbol(isCorrect: option.isCorrect),
                    accent: option.isCorrect
                        ? (draft.type == .multipleChoice ? QuizTheme.publishedGlow : QuizTheme.draftGlow)
                        : QuizTheme.mutedText,
                    canDelete: draft.options.count > QuizBuilderQuestionLimits.minimumOptions,
                    text: optionTextBinding(at: index),
                    onToggleCorrect: { toggleCorrect(at: index) },
                    onDelete: { deleteOption(option.id) }
                )
            }

            if draft.options.count < QuizBuilderQuestionLimits.maximumOptions {
                addOptionButton
            }
        }
        .padding(16)
        .background(QuizBuilderEditorCardBackground())
    }

    private var addOptionButton: some View {
        Button {
            updateDraft { $0.options.append(QuizBuilderAnswerOption()) }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                Text(Strings.QuizBuilder.Action.addOption)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(QuizTheme.draftGlow)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(QuizTheme.draftGlow.opacity(0.8), lineWidth: 1.2)
            )
        }
        .buttonStyle(.plain)
    }

    private var textAnswerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            QuizBuilderEditorSectionLabel(
                icon: "textformat",
                text: Strings.QuizBuilder.Editor.acceptedAnswer
            )
            QuizBuilderOutlinedField {
                TextField(
                    Strings.QuizBuilder.Editor.acceptedAnswerPlaceholder,
                    text: acceptedAnswerBinding
                )
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
                .tint(QuizTheme.draftGlow)
            }
            QuizBuilderEditorCharacterCount(
                current: draft.acceptedTextAnswer.count,
                max: QuizBuilderQuestionLimits.textAnswerMaxLength
            )
        }
        .padding(16)
        .background(QuizBuilderEditorCardBackground())
    }
}

private extension QuizBuilderQuestionEditorView {
    func correctSymbol(isCorrect: Bool) -> String {
        switch draft.type {
        case .singleChoice:
            return isCorrect ? "circle.inset.filled" : "circle"
        case .multipleChoice:
            return isCorrect ? "checkmark.square.fill" : "square"
        case .textAnswer:
            return "circle"
        }
    }

    var promptBinding: Binding<String> {
        Binding(
            get: { draft.prompt },
            set: { newValue in
                updateDraft {
                    $0.prompt = String(newValue.prefix(QuizBuilderQuestionLimits.promptMaxLength))
                }
            }
        )
    }

    var acceptedAnswerBinding: Binding<String> {
        Binding(
            get: { draft.acceptedTextAnswer },
            set: { newValue in
                updateDraft {
                    $0.acceptedTextAnswer = String(
                        newValue.prefix(QuizBuilderQuestionLimits.textAnswerMaxLength)
                    )
                }
            }
        )
    }

    func optionTextBinding(at index: Int) -> Binding<String> {
        Binding(
            get: {
                guard draft.options.indices.contains(index) else { return "" }
                return draft.options[index].text
            },
            set: { newValue in
                updateDraft { question in
                    guard question.options.indices.contains(index) else { return }
                    question.options[index].text = String(
                        newValue.prefix(QuizBuilderQuestionLimits.optionMaxLength)
                    )
                }
            }
        )
    }

    func selectType(_ type: QuizBuilderQuestionType) {
        updateDraft { question in
            question.type = type
            if type == .singleChoice {
                normalizeSingleChoice(&question)
            }
        }
    }

    func toggleCorrect(at index: Int) {
        updateDraft { question in
            guard question.options.indices.contains(index) else { return }
            switch question.type {
            case .singleChoice:
                for optionIndex in question.options.indices {
                    question.options[optionIndex].isCorrect = optionIndex == index
                }
            case .multipleChoice:
                question.options[index].isCorrect.toggle()
            case .textAnswer:
                break
            }
        }
    }

    func deleteOption(_ id: UUID) {
        updateDraft { question in
            question.options.removeAll { $0.id == id }
            if question.type == .singleChoice {
                normalizeSingleChoice(&question)
            }
        }
    }

    func normalizeSingleChoice(_ question: inout QuizBuilderQuestion) {
        guard question.type == .singleChoice else { return }
        guard let firstCorrect = question.options.firstIndex(where: \.isCorrect) else { return }
        for index in question.options.indices {
            question.options[index].isCorrect = index == firstCorrect
        }
    }

    func updateDraft(_ mutate: (inout QuizBuilderQuestion) -> Void) {
        var updated = draft
        mutate(&updated)
        while updated.options.count < QuizBuilderQuestionLimits.minimumOptions {
            updated.options.append(QuizBuilderAnswerOption())
        }
        viewModel.updateEditorDraft(updated)
    }
}

#Preview {
    PreviewContainer()
}

private struct PreviewContainer: View {
    @StateObject private var viewModel = QuizBuilderViewModelImpl(
        coordinator: QuizBuilderCoordinatorImpl()
    )

    var body: some View {
        QuizBuilderQuestionEditorView(viewModel: viewModel)
            .onAppear {
                if viewModel.questionEditor == nil {
                    viewModel.addQuestion()
                }
            }
    }
}
