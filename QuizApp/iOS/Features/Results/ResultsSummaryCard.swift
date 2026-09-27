import SwiftUI

struct ResultsSummaryCard: View {
    let summary: ResultsSummary

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ScoreProgressRing(
                progress: Double(summary.averageScorePercent) / 100,
                percentText: Strings.ResultsHistory.Score.percent(summary.averageScorePercent),
                caption: Strings.ResultsHistory.Summary.average
            )

            VStack(alignment: .leading, spacing: 10) {
                summaryMetric(
                    title: Strings.ResultsHistory.Summary.quizzesCompleted,
                    value: "\(summary.quizzesCompleted)"
                )
                summaryMetric(
                    title: Strings.ResultsHistory.Summary.totalAttempts,
                    value: "\(summary.totalAttempts)"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            streakView
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(QuizTheme.publishedGlow.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: QuizTheme.publishedGlow.opacity(0.22), radius: 14, x: 0, y: 0)
    }

    private func summaryMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var streakView: some View {
        VStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(QuizTheme.draftGlow)
                .shadow(color: QuizTheme.draftGlow.opacity(0.7), radius: 6, x: 0, y: 0)

            Text("\(summary.streakDays)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(QuizTheme.draftGlow)

            Text(Strings.ResultsHistory.Summary.streak)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 72)
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(QuizTheme.draftGlow.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(QuizTheme.draftGlow.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: QuizTheme.draftGlow.opacity(0.25), radius: 8, x: 0, y: 0)
    }
}
