import SwiftUI

struct ProfileQuizStatusChips: View {
    @Binding var filter: ProfileQuizStatusFilter
    let draftCount: Int
    let publishedCount: Int

    var body: some View {
        HStack(spacing: 10) {
            chip(
                title: Strings.Profile.Filter.drafts(draftCount),
                isSelected: filter == .drafts,
                accent: QuizTheme.publishedGlow
            ) {
                filter = .drafts
            }

            chip(
                title: Strings.Profile.Filter.published(publishedCount),
                isSelected: filter == .published,
                accent: QuizTheme.draftGlow
            ) {
                filter = .published
            }

            Spacer(minLength: 0)
        }
    }

    private func chip(
        title: String,
        isSelected: Bool,
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
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
}
