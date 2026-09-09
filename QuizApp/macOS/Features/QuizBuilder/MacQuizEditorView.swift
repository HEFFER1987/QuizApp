import SwiftUI

struct MacQuizEditorView<ViewModel: QuizBuilderViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var publishViewModel: QuizPublishViewModelImpl
    let onPreview: () -> Void
    let onPublish: () -> Void
    let onDetails: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            editorToolbar
            HSplitView {
                questionListColumn
                    .frame(minWidth: 220, idealWidth: 250, maxWidth: 300)
                centerEditorColumn
                    .frame(minWidth: 360)
                MacQuestionInspectorView(viewModel: viewModel)
                    .frame(minWidth: 240, idealWidth: 280, maxWidth: 320)
            }
        }
        .padding(16)
        .onAppear {
            if viewModel.questions.isEmpty {
                viewModel.addQuestion()
            } else {
                viewModel.ensureSelectionAfterChanges()
            }
        }
    }

    private var editorToolbar: some View {
        HStack(spacing: 12) {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)
            Text(viewModel.title.isEmpty ? Strings.QuizBuilder.title : viewModel.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Button("Details", action: onDetails)
            Button("Preview", action: onPreview)
            Button("Publish", action: onPublish)
                .buttonStyle(.borderedProminent)
        }
        .padding(.bottom, 12)
    }

    private var questionListColumn: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Strings.QuizBuilder.Step.questions)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Button {
                viewModel.addQuestion()
            } label: {
                Label(Strings.QuizBuilder.Action.addQuestion, systemImage: "plus")
            }
            .buttonStyle(.bordered)
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(viewModel.questions.enumerated()), id: \.element.id) { index, question in
                        Button {
                            viewModel.selectQuestion(question)
                            viewModel.editQuestion(question)
                        } label: {
                            HStack {
                                Text("\(index + 1)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(QuizTheme.draftGlow)
                                Text(question.prompt.isEmpty ? "Untitled question" : question.prompt)
                                    .lineLimit(1)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(viewModel.selectedQuestionID == question.id
                                          ? QuizTheme.publishedGlow.opacity(0.15)
                                          : Color.black.opacity(0.25))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(QuizTheme.cardFill.opacity(0.5))
        )
    }

    private var centerEditorColumn: some View {
        Group {
            if let editor = viewModel.questionEditor {
                MacInlineQuestionEditorView(
                    viewModel: viewModel,
                    draft: editor.draft
                )
            } else if let question = viewModel.selectedQuestion {
                MacInlineQuestionEditorView(
                    viewModel: viewModel,
                    draft: question
                )
            } else {
                SystemEmptyView(
                    title: "No question selected",
                    message: "Add or select a question to edit"
                )
            }
        }
    }
}

struct MacInlineQuestionEditorView<ViewModel: QuizBuilderViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    let draft: QuizBuilderQuestion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                QuizBuilderQuestionEditorPromptSection(
                    prompt: draftBinding(\.prompt)
                )
                if draft.type != .textAnswer {
                    QuizBuilderQuestionEditorOptionsSection(
                        type: draft.type,
                        options: draft.options,
                        optionText: optionTextBinding,
                        onTips: {},
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
                } else {
                    QuizBuilderEditorExplanationSection(
                        explanation: draftBinding(\.explanation)
                    )
                }
                QuizBuilderEditorExplanationSection(
                    explanation: draftBinding(\.explanation)
                )
            }
            .padding(12)
        }
    }

    private func draftBinding(_ keyPath: WritableKeyPath<QuizBuilderQuestion, String>) -> Binding<String> {
        Binding(
            get: { draft[keyPath: keyPath] },
            set: { newValue in
                updateDraft { $0[keyPath: keyPath] = newValue }
            }
        )
    }

    private func optionTextBinding(at index: Int) -> Binding<String> {
        Binding(
            get: {
                guard draft.options.indices.contains(index) else { return "" }
                return draft.options[index].text
            },
            set: { newValue in
                updateDraft { question in
                    guard question.options.indices.contains(index) else { return }
                    question.options[index].text = String(newValue.prefix(QuizBuilderQuestionLimits.optionMaxLength))
                }
            }
        )
    }

    private func toggleCorrect(at index: Int) {
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

    private func duplicateOption(at index: Int) {
        updateDraft { question in
            guard question.options.indices.contains(index) else { return }
            guard question.options.count < QuizBuilderQuestionLimits.maximumOptions else { return }
            question.options.insert(question.options[index].duplicated(), at: index + 1)
        }
    }

    private func deleteOption(_ id: UUID) {
        updateDraft { question in
            question.options.removeAll { $0.id == id }
        }
    }

    private func moveOption(droppedIDs: [String], to destinationIndex: Int) -> Bool {
        guard let rawID = droppedIDs.first,
              let droppedID = UUID(uuidString: rawID),
              let fromIndex = draft.options.firstIndex(where: { $0.id == droppedID }) else {
            return false
        }
        updateDraft { question in
            question.options.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: destinationIndex)
        }
        return true
    }

    private func updateDraft(_ mutate: (inout QuizBuilderQuestion) -> Void) {
        var updated = draft
        mutate(&updated)
        viewModel.updateEditorDraft(updated)
        if viewModel.questionEditor == nil {
            viewModel.editQuestion(updated)
        }
    }
}

struct MacQuestionInspectorView<ViewModel: QuizBuilderViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    private var draft: QuizBuilderQuestion {
        viewModel.questionEditor?.draft ?? viewModel.selectedQuestion ?? QuizBuilderQuestion()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Inspector")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                QuizBuilderQuestionEditorHeaderRow(
                    index: viewModel.editorQuestionIndex,
                    total: viewModel.editorQuestionTotal,
                    type: draft.type,
                    onSelectType: selectType
                )
                QuizBuilderQuestionEditorSettingsSection(
                    points: draftBinding(\.points),
                    shuffleAnswers: draftBinding(\.shuffleAnswers)
                )
                difficultyPicker
            }
            .padding(12)
        }
    }

    private var difficultyPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Difficulty")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Picker("Difficulty", selection: draftBinding(\.difficulty)) {
                Text("Easy").tag("Easy")
                Text("Medium").tag("Medium")
                Text("Hard").tag("Hard")
            }
            .labelsHidden()
        }
    }

    private func draftBinding<Value>(_ keyPath: WritableKeyPath<QuizBuilderQuestion, Value>) -> Binding<Value> {
        Binding(
            get: { draft[keyPath: keyPath] },
            set: { newValue in
                var updated = draft
                updated[keyPath: keyPath] = newValue
                viewModel.updateEditorDraft(updated)
            }
        )
    }

    private func selectType(_ type: QuizBuilderQuestionType) {
        var updated = draft
        updated.type = type
        viewModel.updateEditorDraft(updated)
    }
}

struct MacQuizDetailsPanel<ViewModel: QuizBuilderViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Strings.QuizBuilder.Step.quizDetails)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            QuizBuilderDetailsForm(viewModel: viewModel)
            HStack {
                TextField("Difficulty", text: $viewModel.difficulty)
                    .textFieldStyle(.roundedBorder)
                TextField("Tags (comma separated)", text: $viewModel.tagsText)
                    .textFieldStyle(.roundedBorder)
            }
            Button("Continue") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(minWidth: 520, minHeight: 560)
    }
}

struct MacQuizPublishView<ViewModel: QuizBuilderViewModel>: View {
    @ObservedObject var builderViewModel: ViewModel
    @ObservedObject var publishViewModel: QuizPublishViewModelImpl
    let onPublished: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Toggle("Shuffle questions", isOn: $publishViewModel.settings.shuffleQuestions)
            Toggle("Shuffle answers", isOn: $publishViewModel.settings.shuffleAnswers)
            Stepper("Time limit: \(publishViewModel.settings.timeLimitMinutes) min", value: $publishViewModel.settings.timeLimitMinutes, in: 0...180)
            Toggle("Show correct answers", isOn: $publishViewModel.settings.showCorrectAnswers)
            Toggle("Allow retry", isOn: $publishViewModel.settings.allowRetry)
            Stepper("Passing score: \(publishViewModel.settings.passingScorePercent)%", value: $publishViewModel.settings.passingScorePercent, in: 0...100)
            TextField("Unique link", text: $publishViewModel.settings.uniqueLink)
            Button("Publish QUIZ") {
                publishViewModel.publish(title: builderViewModel.title)
                onPublished()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
        .frame(minWidth: 420, minHeight: 420)
    }
}

struct MacQuizPublishedSuccessView: View {
    @ObservedObject var publishViewModel: QuizPublishViewModelImpl
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(QuizTheme.excellentGlow)
            Text("Quiz Published")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            if let info = publishViewModel.publishedInfo {
                Text(info.title)
                    .foregroundStyle(.white)
                Text(info.link)
                    .foregroundStyle(QuizTheme.publishedGlow)
                HStack {
                    Button("Copy Link", action: publishViewModel.copyLink)
                    ShareLink(item: info.link) { Text("Share") }
                    Button("Open Quiz") { onClose() }
                }
            }
            Button("Done", action: onClose)
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MacQuizEditorView(
        viewModel: QuizBuilderViewModelImpl(coordinator: MacQuizBuilderCoordinatorImpl()),
        publishViewModel: QuizPublishViewModelImpl(),
        onPreview: {},
        onPublish: {},
        onDetails: {},
        onClose: {}
    )
    .background(Color.black)
}
