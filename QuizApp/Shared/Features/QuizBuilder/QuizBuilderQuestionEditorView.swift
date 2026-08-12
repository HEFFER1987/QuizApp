import SwiftUI

struct QuizBuilderQuestionEditorView<ViewModel: QuizBuilderViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var showTips = false

    private var draft: QuizBuilderQuestion {
        viewModel.questionEditor?.draft ?? QuizBuilderQuestion()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QuizListBackgroundView()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        QuizBuilderQuestionEditorHeaderRow(
                            index: viewModel.editorQuestionIndex,
                            total: viewModel.editorQuestionTotal,
                            type: draft.type,
                            onSelectType: selectType
                        )
                        QuizBuilderQuestionEditorPromptSection(prompt: draftField(\.prompt))
                        optionsSection
                        QuizBuilderEditorExplanationSection(
                            explanation: draftField(\.explanation)
                        )
                        QuizBuilderQuestionEditorSettingsSection(
                            points: draftField(\.points),
                            shuffleAnswers: draftField(\.shuffleAnswers)
                        )
                        QuizBuilderEditorFooterButtons(
                            canSave: draft.isValid,
                            onDelete: { viewModel.deleteQuestionFromEditor() },
                            onSaveAndClose: { viewModel.saveQuestionEditor() }
                        )
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle(Strings.QuizBuilder.Editor.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { editorToolbar }
            .toolbarBackground(.hidden, for: .navigationBar)
            .alert(
                Strings.QuizBuilder.Editor.tipsTitle,
                isPresented: $showTips
            ) {
                Button(Strings.QuizBuilder.Action.cancel, role: .cancel) {}
            } message: {
                Text(Strings.QuizBuilder.Editor.tipsMessage)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    @ToolbarContentBuilder
    private var editorToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                viewModel.cancelQuestionEditor()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(QuizTheme.draftGlow)
            }
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

    private var optionsSection: some View {
        QuizBuilderQuestionEditorOptionsSection(
            type: draft.type,
            options: draft.options,
            optionText: optionTextBinding,
            onTips: { showTips = true },
            onToggleCorrect: toggleCorrect,
            onDuplicate: duplicateOption,
            onDelete: deleteOption,
            onAdd: {
                let option = QuizBuilderAnswerOption()
                updateDraft { $0.options.append(option) }
                return option.id
            },
            onMove: moveOption
        )
    }
}

private extension QuizBuilderQuestionEditorView {
    func draftField<Value>(
        _ keyPath: WritableKeyPath<QuizBuilderQuestion, Value>
    ) -> Binding<Value> {
        Binding(
            get: { draft[keyPath: keyPath] },
            set: { newValue in
                updateDraft { $0[keyPath: keyPath] = newValue }
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
            }
        }
    }

    func duplicateOption(at index: Int) {
        updateDraft { question in
            guard question.options.indices.contains(index) else { return }
            guard question.options.count < QuizBuilderQuestionLimits.maximumOptions else { return }
            question.options.insert(question.options[index].duplicated(), at: index + 1)
            if question.type == .singleChoice {
                normalizeSingleChoice(&question)
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

    func moveOption(droppedIDs: [String], to destinationIndex: Int) -> Bool {
        guard let rawID = droppedIDs.first,
              let droppedID = UUID(uuidString: rawID),
              let fromIndex = draft.options.firstIndex(where: { $0.id == droppedID }),
              fromIndex != destinationIndex else {
            return false
        }

        var toOffset = destinationIndex
        if fromIndex < destinationIndex {
            toOffset += 1
        }

        updateDraft { question in
            question.options.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toOffset
            )
        }
        return true
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
