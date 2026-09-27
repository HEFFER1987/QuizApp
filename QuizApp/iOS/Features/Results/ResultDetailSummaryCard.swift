import SwiftUI

struct ResultDetailSummaryCard: View {
    let detail: QuizResultDetail

    private var result: QuizResult { detail.result }

    private var glowColor: Color {
        QuizTheme.glowColor(for: result.iconGlow)
    }

    private var ringColor: Color {
        QuizTheme.scoreBadgeColor(for: result.scorePercent)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerRow
            statsRow
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(glowColor.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: glowColor.opacity(0.22), radius: 14, x: 0, y: 0)
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: 12) {
            HexagonIconView(
                systemName: result.iconName,
                glowColor: glowColor,
                size: 48,
                iconSize: 18
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(result.quizTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(
                    Strings.ResultsDetail.meta(
                        formattedCompletedAt(result.completedAt),
                        difficultyTitle(detail.difficulty)
                    )
                )
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
                .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
    }

    private var statsRow: some View {
        HStack(alignment: .center, spacing: 12) {
            ScoreProgressRing(
                progress: Double(result.scorePercent) / 100,
                percentText: Strings.ResultsHistory.Score.percent(result.scorePercent),
                caption: Strings.ResultsHistory.Stats.score(result.correctCount, result.totalCount),
                ringColor: ringColor,
                lineWidth: 7,
                size: 92
            )

            Spacer(minLength: 4)

            statChip(
                icon: "star.fill",
                title: Strings.ResultsHistory.Stats.xp(result.xpEarned),
                accent: QuizTheme.draftGlow
            )

            statChip(
                icon: "clock.fill",
                title: "\(formattedDuration(result.durationSeconds))\n\(Strings.ResultsDetail.time)",
                accent: QuizTheme.publishedGlow
            )
        }
    }

    private func statChip(icon: String, title: String, accent: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(accent)
                .shadow(color: accent.opacity(0.55), radius: 6, x: 0, y: 0)

            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(accent)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(width: 96)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(accent.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(accent.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: accent.opacity(0.22), radius: 8, x: 0, y: 0)
    }

    private func difficultyTitle(_ difficulty: QuizDifficulty) -> String {
        switch difficulty {
        case .easy:
            return Strings.ResultsDetail.Difficulty.easy
        case .medium:
            return Strings.ResultsDetail.Difficulty.medium
        case .hard:
            return Strings.ResultsDetail.Difficulty.hard
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
