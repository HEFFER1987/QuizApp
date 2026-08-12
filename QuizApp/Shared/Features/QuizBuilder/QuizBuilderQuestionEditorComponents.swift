import SwiftUI

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
    let icon: String
    let text: String

    var body: some View {
        Label {
            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(QuizTheme.draftGlow)
        }
        .labelStyle(.titleAndIcon)
    }
}

struct QuizBuilderEditorCharacterCount: View {
    let current: Int
    let max: Int

    var body: some View {
        HStack {
            Spacer()
            Text(Strings.QuizBuilder.characterCount(current, max))
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
        }
    }
}

struct QuizBuilderQuestionTypeChip: View {
    let type: QuizBuilderQuestionType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: type.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                Text(type.title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(isSelected ? type.accentColor : QuizTheme.mutedText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.35))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? type.accentColor : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 1.4 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct QuizBuilderOptionEditorRow: View {
    let correctSymbol: String
    let accent: Color
    let canDelete: Bool
    @Binding var text: String
    let onToggleCorrect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onToggleCorrect) {
                Image(systemName: correctSymbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Strings.QuizBuilder.Editor.correct)

            QuizBuilderOutlinedField {
                TextField(Strings.QuizBuilder.Editor.optionPlaceholder, text: $text)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .tint(QuizTheme.draftGlow)
            }

            if canDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(QuizTheme.mutedText)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
