import SwiftUI

struct ResultCardView: View {
    let result: QuizResult
    let onTap: () -> Void

    private var glowColor: Color {
        QuizTheme.glowColor(for: result.iconGlow)
    }

    private var badgeColor: Color {
        QuizTheme.scoreBadgeColor(for: result.scorePercent)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                HexagonIconView(
                    systemName: result.iconName,
                    glowColor: glowColor,
                    size: 48,
                    iconSize: 18
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(result.quizTitle)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(formattedCompletedAt(result.completedAt))
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(QuizTheme.mutedText)

                    statsRow
                }

                Spacer(minLength: 4)

                scoreBadge

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(QuizTheme.mutedText)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(QuizTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statItem(
                icon: "checkmark.circle",
                text: Strings.ResultsHistory.Stats.score(result.correctCount, result.totalCount),
                color: QuizTheme.mutedText
            )
            statItem(
                icon: "clock",
                text: Strings.ResultsHistory.Stats.duration(formattedDuration(result.durationSeconds)),
                color: QuizTheme.mutedText
            )
            statItem(
                icon: "star.fill",
                text: Strings.ResultsHistory.Stats.xp(result.xpEarned),
                color: QuizTheme.draftGlow
            )
        }
    }

    private func statItem(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color.opacity(0.9))
            Text(text)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(color)
        }
    }

    private var scoreBadge: some View {
        VStack(spacing: 2) {
            if result.scorePercent == 100 {
                Image(systemName: "crown.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(badgeColor)
                    .shadow(color: badgeColor.opacity(0.6), radius: 4, x: 0, y: 0)
            }

            Text(Strings.ResultsHistory.Score.percent(result.scorePercent))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(badgeColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(badgeColor.opacity(0.16))
                )
                .overlay(
                    Capsule()
                        .stroke(badgeColor.opacity(0.85), lineWidth: 1)
                )
                .shadow(color: badgeColor.opacity(0.35), radius: 6, x: 0, y: 0)
        }
    }

    private func formattedDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }

    private func formattedCompletedAt(_ date: Date) -> String {
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeText = timeFormatter.string(from: date)

        if calendar.isDateInYesterday(date) {
            return Strings.ResultsHistory.Date.yesterday(timeText)
        }

        let dayFormatter = DateFormatter()
        dayFormatter.dateStyle = .medium
        dayFormatter.timeStyle = .none
        return Strings.ResultsHistory.Date.at(dayFormatter.string(from: date), timeText)
    }
}
