import SwiftUI

struct QuizBuilderQuestionEditorHeaderRow: View {
    let index: Int
    let total: Int
    let type: QuizBuilderQuestionType
    let onSelectType: (QuizBuilderQuestionType) -> Void

    var body: some View {
        HStack(spacing: 12) {
            QuizBuilderEditorProgressPill(index: index, total: total)
            Spacer()
            Menu {
                ForEach(QuizBuilderQuestionType.allCases) { questionType in
                    Button {
                        onSelectType(questionType)
                    } label: {
                        Label(questionType.title, systemImage: questionType.systemImage)
                    }
                }
            } label: {
                QuizBuilderEditorTypeMenuLabel(type: type)
            }
        }
    }
}

struct QuizBuilderQuestionEditorPromptSection: View {
    @Binding var prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            QuizBuilderEditorSectionLabel(
                text: Strings.QuizBuilder.Editor.prompt,
                isRequired: true
            )
            QuizBuilderOutlinedField(minHeight: 96) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: cappedPromptBinding)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .tint(QuizTheme.draftGlow)
                        .frame(minHeight: 76)
                    if prompt.isEmpty {
                        Text(Strings.QuizBuilder.Editor.promptPlaceholder)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(QuizTheme.mutedText.opacity(0.7))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
            }
            HStack {
                Spacer()
                QuizBuilderEditorCharacterCount(
                    current: prompt.count,
                    max: QuizBuilderQuestionLimits.promptMaxLength
                )
            }
        }
        .padding(16)
        .background(QuizBuilderEditorCardBackground())
    }

    private var cappedPromptBinding: Binding<String> {
        Binding(
            get: { prompt },
            set: { prompt = String($0.prefix(QuizBuilderQuestionLimits.promptMaxLength)) }
        )
    }
}

struct QuizBuilderEditorExplanationSection: View {
    @Binding var explanation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            QuizBuilderEditorSectionLabel(text: Strings.QuizBuilder.Editor.explanation)
            QuizBuilderOutlinedField(minHeight: 96) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: cappedExplanationBinding)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .tint(QuizTheme.draftGlow)
                        .frame(minHeight: 76)
                    if explanation.isEmpty {
                        Text(Strings.QuizBuilder.Editor.explanationPlaceholder)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(QuizTheme.mutedText.opacity(0.7))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
            }
            HStack {
                Spacer()
                QuizBuilderEditorCharacterCount(
                    current: explanation.count,
                    max: QuizBuilderQuestionLimits.explanationMaxLength
                )
            }
        }
        .padding(16)
        .background(QuizBuilderEditorCardBackground())
    }

    private var cappedExplanationBinding: Binding<String> {
        Binding(
            get: { explanation },
            set: {
                explanation = String($0.prefix(QuizBuilderQuestionLimits.explanationMaxLength))
            }
        )
    }
}

struct QuizBuilderQuestionEditorSettingsSection: View {
    @Binding var points: Int
    @Binding var shuffleAnswers: Bool

    var body: some View {
        VStack(spacing: 10) {
            QuizBuilderEditorSettingsRow(
                icon: "star.fill",
                title: Strings.QuizBuilder.Editor.points
            ) {
                QuizBuilderEditorPointsStepper(
                    value: points,
                    onDecrement: {
                        points = max(QuizBuilderQuestionLimits.minimumPoints, points - 1)
                    },
                    onIncrement: {
                        points = min(QuizBuilderQuestionLimits.maximumPoints, points + 1)
                    }
                )
            }

            QuizBuilderEditorSettingsRow(
                icon: "shuffle",
                title: Strings.QuizBuilder.Editor.shuffleAnswers
            ) {
                Toggle("", isOn: $shuffleAnswers)
                    .labelsHidden()
                    .tint(QuizBuilderEditorAccent.utilityBlue)
            }
        }
        .padding(16)
        .background(QuizBuilderEditorCardBackground())
    }
}

struct QuizBuilderQuestionEditorOptionsSection: View {
    let type: QuizBuilderQuestionType
    let options: [QuizBuilderAnswerOption]
    let optionText: (Int) -> Binding<String>
    let onTips: () -> Void
    let onToggleCorrect: (Int) -> Void
    let onDuplicate: (Int) -> Void
    let onDelete: (UUID) -> Void
    let onAdd: () -> UUID
    let onMove: ([String], Int) -> Bool

    @State private var targetedOptionID: UUID?
    @FocusState private var focusedOptionID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                QuizBuilderEditorSectionLabel(text: Strings.QuizBuilder.Editor.options)
                Spacer()
                QuizBuilderEditorTipsButton(action: onTips)
            }

            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                optionRow(index: index, option: option)
                    .dropDestination(
                        for: String.self,
                        action: { items, _ in
                            onMove(items, index)
                        },
                        isTargeted: { isTargeted in
                            if isTargeted {
                                targetedOptionID = option.id
                            } else if targetedOptionID == option.id {
                                targetedOptionID = nil
                            }
                        }
                    )
            }

            if options.count < QuizBuilderQuestionLimits.maximumOptions {
                Button {
                    let newOptionID = onAdd()
                    Task { @MainActor in
                        focusedOptionID = newOptionID
                    }
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
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(QuizBuilderEditorCardBackground())
    }

    private func optionRow(index: Int, option: QuizBuilderAnswerOption) -> some View {
        let accent: Color = option.isCorrect
            ? (type == .multipleChoice ? QuizTheme.publishedGlow : QuizTheme.draftGlow)
            : QuizTheme.mutedText

        return QuizBuilderOptionEditorRow(
            optionID: option.id,
            correctSymbol: correctSymbol(isCorrect: option.isCorrect),
            accent: accent,
            isCorrect: option.isCorrect,
            isDropTargeted: targetedOptionID == option.id,
            canDelete: options.count > QuizBuilderQuestionLimits.minimumOptions,
            canDuplicate: options.count < QuizBuilderQuestionLimits.maximumOptions,
            showsDragHandle: true,
            text: optionText(index),
            focusedOptionID: $focusedOptionID,
            onToggleCorrect: { onToggleCorrect(index) },
            onDuplicate: { onDuplicate(index) },
            onDelete: { onDelete(option.id) }
        )
    }

    private func correctSymbol(isCorrect: Bool) -> String {
        switch type {
        case .singleChoice:
            return isCorrect ? "circle.inset.filled" : "circle"
        case .multipleChoice:
            return isCorrect ? "checkmark.square.fill" : "square"
        case .textAnswer:
            return "textformat"
        }
    }
}
