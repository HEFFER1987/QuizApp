import SwiftUI

struct QuizBuilderQuestionsForm<ViewModel: QuizBuilderViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var showDeleteAllConfirmation = false

    var body: some View {
        VStack(spacing: 14) {
            questionsCard
            addQuestionButton
        }
        .confirmationDialog(
            Strings.QuizBuilder.Questions.DeleteAll.title,
            isPresented: $showDeleteAllConfirmation,
            titleVisibility: .visible
        ) {
            Button(Strings.QuizBuilder.Action.deleteAll, role: .destructive) {
                viewModel.deleteAllQuestions()
            }
        } message: {
            Text(Strings.QuizBuilder.Questions.DeleteAll.message)
        }
    }

    private var questionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            QuizBuilderQuestionsHeader(
                count: viewModel.questions.count,
                isDeleteAllDisabled: viewModel.questions.isEmpty,
                onDeleteAll: { showDeleteAllConfirmation = true }
            )
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.questions.isEmpty {
            VStack(spacing: 12) {
                Text(Strings.QuizBuilder.Questions.empty)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                QuizBuilderQuestionsDragZone()
            }
        } else {
            questionList
            QuizBuilderQuestionsDragZone()
        }
    }

    private var questionList: some View {
        VStack(spacing: 8) {
            ForEach(Array(viewModel.questions.enumerated()), id: \.element.id) { index, question in
                QuizBuilderQuestionRow(
                    question: question,
                    index: index + 1,
                    onEdit: { viewModel.editQuestion(question) },
                    onDuplicate: { viewModel.duplicateQuestion(question) },
                    onDelete: { viewModel.deleteQuestion(question) }
                )
                .draggable(question.id.uuidString) {
                    QuizBuilderQuestionRow(
                        question: question,
                        index: index + 1,
                        interactive: false,
                        onEdit: {},
                        onDuplicate: {},
                        onDelete: {}
                    )
                    .frame(width: 320)
                    .opacity(0.92)
                }
                .dropDestination(for: String.self) { items, _ in
                    return moveQuestion(droppedIDs: items, to: index)
                }
            }
        }
    }

    private var addQuestionButton: some View {
        Button {
            viewModel.addQuestion()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .semibold))
                Text(Strings.QuizBuilder.Action.addQuestion)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(QuizTheme.draftGlow)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.35))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(QuizTheme.draftGlow, lineWidth: 1.4)
            )
        }
        .buttonStyle(.plain)
    }

    private func moveQuestion(droppedIDs: [String], to index: Int) -> Bool {
        guard let rawID = droppedIDs.first,
              let droppedID = UUID(uuidString: rawID),
              let fromIndex = viewModel.questions.firstIndex(where: { $0.id == droppedID }),
              fromIndex != index
        else { return false }

        var destination = index
        if fromIndex < index {
            destination += 1
        }
        viewModel.moveQuestions(from: IndexSet(integer: fromIndex), to: destination)
        return true
    }
}

private struct QuizBuilderQuestionsHeader: View {
    let count: Int
    let isDeleteAllDisabled: Bool
    let onDeleteAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(QuizTheme.draftGlow)

                Text(Strings.QuizBuilder.Questions.sectionTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(QuizTheme.draftGlow.opacity(0.85))
                    )

                Spacer(minLength: 8)

                Menu {
                    Button(role: .destructive, action: onDeleteAll) {
                        Label(Strings.QuizBuilder.Action.deleteAll, systemImage: "trash")
                    }
                    .disabled(isDeleteAllDisabled)
                } label: {
                    HStack(spacing: 6) {
                        Text(Strings.QuizBuilder.Action.bulkActions)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(QuizTheme.draftGlow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(QuizTheme.draftGlow, lineWidth: 1.2)
                    )
                }
            }

            Text(Strings.QuizBuilder.Questions.reorderHint)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
        }
    }
}

private struct QuizBuilderQuestionsDragZone: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(QuizTheme.mutedText.opacity(0.7))
            Text(Strings.QuizBuilder.Questions.dragHere)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    QuizTheme.mutedText.opacity(0.45),
                    style: StrokeStyle(lineWidth: 1.2, dash: [6, 5])
                )
        )
    }
}

private struct QuizBuilderQuestionRow: View {
    let question: QuizBuilderQuestion
    let index: Int
    var interactive: Bool = true
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(QuizTheme.mutedText)

            Text("\(index)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(QuizTheme.draftGlow)
                .frame(width: 28, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(QuizTheme.draftGlow, lineWidth: 1.2)
                )

            Button(action: onEdit) {
                Text(question.prompt.isEmpty ? Strings.QuizBuilder.Editor.promptPlaceholder : question.prompt)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(question.prompt.isEmpty ? QuizTheme.mutedText : .white)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.plain)
            .disabled(!interactive)

            typeBadge

            if interactive {
                Menu {
                    Button(action: onEdit) {
                        Label(Strings.QuizBuilder.Action.edit, systemImage: "pencil")
                    }
                    Button(action: onDuplicate) {
                        Label(Strings.QuizBuilder.Action.duplicate, systemImage: "plus.square.on.square")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label(Strings.QuizBuilder.Action.delete, systemImage: "trash")
                    }
                } label: {
                    ellipsisIcon
                }
            } else {
                ellipsisIcon
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var typeBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: question.type.systemImage)
                .font(.system(size: 11, weight: .semibold))
            Text(question.type.title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .lineLimit(1)
        }
        .foregroundStyle(question.type.accentColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(question.type.accentColor.opacity(0.12))
        )
    }

    private var ellipsisIcon: some View {
        Image(systemName: "ellipsis")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(QuizTheme.mutedText)
            .frame(width: 28, height: 28)
    }
}

#Preview {
    ZStack {
        QuizListBackgroundView()
        ScrollView {
            QuizBuilderQuestionsForm(
                viewModel: QuizBuilderViewModelImpl(coordinator: QuizBuilderCoordinatorImpl())
            )
            .padding()
        }
    }
}
