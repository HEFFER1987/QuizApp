import SwiftUI

struct QuizCardView: View {
    let quiz: Quiz
    var onCardTap: (() -> Void)?
    let onMenuTap: () -> Void

    private var glowColor: Color {
        QuizTheme.glowColor(for: quiz.status)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            iconView
            contentView
        }
        .padding(16)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onTapGesture(perform: onCardTap)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(alignment: .topTrailing) {
            menuButton
                .padding(.top, 10)
                .padding(.trailing, 12)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(glowColor.opacity(0.9), lineWidth: 1.2)
        )
        .shadow(color: glowColor.opacity(0.4), radius: 12, x: 0, y: 0)
        .shadow(color: glowColor.opacity(0.2), radius: 4, x: 0, y: 0)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onTapGesture {
            onCardTap?()
        }
    }

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(glowColor.opacity(0.18))
                .frame(width: 52, height: 52)
            Circle()
                .stroke(glowColor.opacity(0.85), lineWidth: 1.2)
                .frame(width: 52, height: 52)
                .shadow(color: glowColor.opacity(0.45), radius: 6, x: 0, y: 0)
            Image(systemName: quiz.iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(glowColor)
                .shadow(color: glowColor.opacity(0.5), radius: 4, x: 0, y: 0)
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Text(quiz.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer(minLength: 8)
                statusBadge
                    .padding(.trailing, 24)
            }

            if let subtitle = quiz.subtitle {
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
            }

            statsColumn
        }
    }

    private var statusBadge: some View {
        Text(statusTitle)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(glowColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(glowColor.opacity(0.18))
            )
            .overlay(
                Capsule()
                    .stroke(glowColor.opacity(0.75), lineWidth: 1)
            )
    }

    private var statsColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            statLabel(
                icon: "questionmark.circle",
                text: Strings.QuizList.Stats.questions(quiz.questionCount)
            )

            if quiz.status == .published, let attemptCount = quiz.attemptCount {
                publishedAttemptsLabel(attemptCount: attemptCount)
            } else if let updatedAt = quiz.updatedAt {
                statLabel(
                    icon: "clock",
                    text: relativeUpdatedText(for: updatedAt)
                )
            }
        }
    }

    private func publishedAttemptsLabel(attemptCount: Int) -> some View {
        Label {
            HStack(spacing: 0) {
                Text(Strings.QuizList.Stats.attempts(attemptCount))
                    .foregroundStyle(QuizTheme.mutedText)
                if let averageScorePercent = quiz.averageScorePercent {
                    Text(" · \(averageScorePercent)%")
                        .foregroundStyle(QuizTheme.publishedGlow)
                }
            }
            .font(.system(size: 13, weight: .regular, design: .rounded))
        } icon: {
            Image(systemName: "person.2")
                .foregroundStyle(glowColor)
        }
        .labelStyle(.titleAndIcon)
    }

    private func statLabel(icon: String, text: String) -> some View {
        Label {
            Text(text)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(glowColor)
        }
        .labelStyle(.titleAndIcon)
    }

    private var menuButton: some View {
        Button(action: onMenuTap) {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(glowColor.opacity(0.9))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
    }

    private var statusTitle: String {
        switch quiz.status {
        case .draft:
            return Strings.QuizList.Status.draft
        case .published:
            return Strings.QuizList.Status.published
        }
    }

    private func relativeUpdatedText(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relative = formatter.localizedString(for: date, relativeTo: Date())
        return Strings.QuizList.Stats.updated(relative)
    }
}
