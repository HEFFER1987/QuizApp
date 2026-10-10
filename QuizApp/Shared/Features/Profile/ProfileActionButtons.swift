import SwiftUI

struct ProfileActionButtons: View {
    let shareText: String
    let onEdit: () -> Void
    var showsPublishingActions: Bool = true

    var body: some View {
        if !showsPublishingActions {
            EmptyView()
        } else {
            publishingActions
        }
    }

    private var publishingActions: some View {
        HStack(spacing: 12) {
            ShareLink(item: shareText) {
                actionLabel(
                    title: Strings.Profile.Action.share,
                    systemName: "square.and.arrow.up",
                    accent: QuizTheme.publishedGlow
                )
            }
            .disabled(shareText.isEmpty)
            .buttonStyle(.plain)

            Button(action: onEdit) {
                actionLabel(
                    title: Strings.Profile.Action.edit,
                    systemName: "pencil",
                    accent: QuizTheme.draftGlow
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func actionLabel(title: String, systemName: String, accent: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(accent)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(accent.opacity(0.9), lineWidth: 1.2)
        )
        .shadow(color: accent.opacity(0.28), radius: 10, x: 0, y: 0)
    }
}
