import SwiftUI

struct ResultsFilterChips: View {
    @Binding var filter: ResultsFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ResultsFilter.allCases, id: \.self) { item in
                    chipButton(for: item)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func chipButton(for item: ResultsFilter) -> some View {
        let isSelected = filter == item
        let accent = accentColor(for: item)

        return Button {
            filter = item
        } label: {
            Text(title(for: item))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? accent : QuizTheme.mutedText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(QuizTheme.cardFill)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? accent.opacity(0.95) : Color.white.opacity(0.12), lineWidth: 1.2)
                )
                .shadow(color: isSelected ? accent.opacity(0.35) : .clear, radius: 8, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }

    private func title(for item: ResultsFilter) -> String {
        switch item {
        case .all:
            return Strings.ResultsHistory.Filter.all
        case .excellent:
            return Strings.ResultsHistory.Filter.excellent
        case .needsReview:
            return Strings.ResultsHistory.Filter.needsReview
        case .composite:
            return Strings.ResultsHistory.Filter.composite
        }
    }

    private func accentColor(for item: ResultsFilter) -> Color {
        switch item {
        case .all:
            return QuizTheme.activeTab
        case .excellent:
            return QuizTheme.excellentGlow
        case .needsReview:
            return QuizTheme.reviewGlow
        case .composite:
            return QuizTheme.publishedGlow
        }
    }
}
