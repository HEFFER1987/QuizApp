import SwiftUI

enum QuizBuilderEditorAccent {
    static let utilityBlue = Color(red: 0.35, green: 0.62, blue: 1.0)
    static let destructive = Color(red: 1.0, green: 0.32, blue: 0.32)
}

struct QuizBuilderEditorCardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(QuizTheme.cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

struct QuizBuilderEditorSectionLabel: View {
    let text: String
    var isRequired: Bool = false

    var body: some View {
        HStack(spacing: 2) {
            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            if isRequired {
                Text("*")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(QuizBuilderEditorAccent.destructive)
            }
        }
    }
}

struct QuizBuilderEditorCharacterCount: View {
    let current: Int
    let max: Int

    var body: some View {
        Text(Strings.QuizBuilder.characterCount(current, max))
            .font(.system(size: 12, weight: .regular, design: .rounded))
            .foregroundStyle(QuizTheme.mutedText)
    }
}

struct QuizBuilderEditorProgressPill: View {
    let index: Int
    let total: Int

    var body: some View {
        Text(Strings.QuizBuilder.Editor.progress(index, total))
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(QuizTheme.draftGlow)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(QuizTheme.draftGlow.opacity(0.85), lineWidth: 1.2)
            )
    }
}

struct QuizBuilderEditorTypeMenuLabel: View {
    let type: QuizBuilderQuestionType

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: type.systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(type.accentColor)
            Text(type.title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(QuizTheme.mutedText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(Color.black.opacity(0.35))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct QuizBuilderEditorTipsButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text(Strings.QuizBuilder.Editor.tips)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(QuizBuilderEditorAccent.utilityBlue)
        }
        .buttonStyle(.plain)
    }
}

struct QuizBuilderEditorPointsStepper: View {
    let value: Int
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    private var canDecrement: Bool {
        value > QuizBuilderQuestionLimits.minimumPoints
    }

    private var canIncrement: Bool {
        value < QuizBuilderQuestionLimits.maximumPoints
    }

    var body: some View {
        HStack(spacing: 0) {
            stepperButton(
                systemImage: "minus",
                enabled: canDecrement,
                action: onDecrement
            )
            Text("\(value)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(minWidth: 28)
            stepperButton(
                systemImage: "plus",
                enabled: canIncrement,
                action: onIncrement
            )
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.35))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(QuizTheme.draftGlow, lineWidth: 1.4)
        )
    }

    private func stepperButton(
        systemImage: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(enabled ? QuizTheme.draftGlow : QuizTheme.mutedText)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct QuizBuilderEditorSettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(QuizTheme.draftGlow)
                .frame(width: 22)
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct QuizBuilderEditorFooterButtons: View {
    let canSave: Bool
    let onDelete: () -> Void
    let onSaveAndClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: onDelete) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .semibold))
                        Text(Strings.QuizBuilder.Editor.deleteQuestion)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .foregroundStyle(QuizBuilderEditorAccent.destructive)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(QuizBuilderEditorAccent.destructive, lineWidth: 1.6)
                    )
                }
                .buttonStyle(.plain)

                Button(action: onSaveAndClose) {
                    Text(Strings.QuizBuilder.Editor.saveAndClose)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(canSave ? QuizTheme.draftGlow : QuizTheme.draftGlow.opacity(0.35))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
            }

            Text(Strings.QuizBuilder.Editor.autosaveHint)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
}

struct QuizBuilderOptionEditorRow: View {
    let optionID: UUID
    let correctSymbol: String
    let accent: Color
    let isCorrect: Bool
    let isDropTargeted: Bool
    let canDelete: Bool
    let canDuplicate: Bool
    let showsDragHandle: Bool
    @Binding var text: String
    var focusedOptionID: FocusState<UUID?>.Binding
    let onToggleCorrect: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            if showsDragHandle {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QuizTheme.mutedText.opacity(0.85))
                    .frame(width: 22, height: 28)
                    .contentShape(Rectangle())
                    .draggable(optionID.uuidString)
                    .accessibilityLabel(Strings.QuizBuilder.Questions.reorderHint)
            } else {
                Color.clear
                    .frame(width: 22, height: 28)
            }

            Button(action: onToggleCorrect) {
                Image(systemName: correctSymbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Strings.QuizBuilder.Editor.correct)

            HStack(spacing: 8) {
                TextField(Strings.QuizBuilder.Editor.optionPlaceholder, text: $text)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .tint(QuizTheme.draftGlow)
                    .focused(focusedOptionID, equals: optionID)

                if isCorrect {
                    Text(Strings.QuizBuilder.Editor.correct)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(QuizTheme.draftGlow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule(style: .continuous)
                                .fill(QuizTheme.draftGlow.opacity(0.16))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.35))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isCorrect ? QuizTheme.draftGlow : Color.white.opacity(0.1),
                        lineWidth: isCorrect ? 1.4 : 1
                    )
            )

            Button(action: onDuplicate) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        canDuplicate
                            ? QuizBuilderEditorAccent.utilityBlue
                            : QuizTheme.mutedText.opacity(0.5)
                    )
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(!canDuplicate)
            .accessibilityLabel(Strings.QuizBuilder.Action.duplicate)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        canDelete
                            ? QuizBuilderEditorAccent.destructive
                            : QuizTheme.mutedText.opacity(0.5)
                    )
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(!canDelete)
            .accessibilityLabel(Strings.QuizBuilder.Action.delete)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    isDropTargeted
                        ? QuizTheme.draftGlow.opacity(0.12)
                        : Color.clear
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    isDropTargeted ? QuizTheme.draftGlow.opacity(0.7) : Color.clear,
                    lineWidth: 1.4
                )
        )
    }
}
