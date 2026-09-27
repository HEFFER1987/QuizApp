import SwiftUI

struct FilterTabBar: View {
    @Binding var filter: QuizListFilter

    var body: some View {
        HStack(spacing: 24) {
            ForEach(QuizListFilter.allCases, id: \.self) { item in
                filterButton(for: item)
            }
            Spacer(minLength: 0)
        }
    }

    private func filterButton(for item: QuizListFilter) -> some View {
        Button {
            filter = item
        } label: {
            VStack(spacing: 8) {
                Text(title(for: item))
                    .font(.system(size: 16, weight: filter == item ? .semibold : .regular, design: .rounded))
                    .foregroundStyle(filter == item ? QuizTheme.activeTab : QuizTheme.mutedText)

                Capsule()
                    .fill(filter == item ? QuizTheme.activeTab : Color.clear)
                    .frame(height: 3)
                    .shadow(color: filter == item ? QuizTheme.activeTab.opacity(0.6) : .clear, radius: 4)
            }
        }
        .buttonStyle(.plain)
    }

    private func title(for filter: QuizListFilter) -> String {
        switch filter {
        case .all:
            return Strings.QuizList.Filter.all
        case .drafts:
            return Strings.QuizList.Filter.drafts
        case .published:
            return Strings.QuizList.Filter.published
        }
    }
}
