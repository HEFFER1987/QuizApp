import SwiftUI

struct ResultDetailQuestionFilterBar: View {
    @Binding var filter: ResultQuestionFilter
    let errorCount: Int

    var body: some View {
        HStack(spacing: 10) {
            filterButton(
                title: Strings.ResultsDetail.Filter.all,
                isSelected: filter == .all
            ) {
                filter = .all
            }

            filterButton(
                title: Strings.ResultsDetail.Filter.errorsOnly(errorCount),
                isSelected: filter == .errorsOnly
            ) {
                filter = .errorsOnly
            }

            Spacer(minLength: 0)
        }
    }

    private func filterButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let accent = QuizTheme.draftGlow

        return Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? accent : QuizTheme.mutedText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(QuizTheme.cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            isSelected ? accent.opacity(0.95) : Color.white.opacity(0.12),
                            lineWidth: 1.2
                        )
                )
                .shadow(color: isSelected ? accent.opacity(0.35) : .clear, radius: 8, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }
}
