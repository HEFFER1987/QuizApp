import SwiftUI

struct ProfileStatisticsGrid: View {
    let statistics: ProfileStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.Profile.Statistics.title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                statTile(
                    icon: "clipboard.fill",
                    glow: QuizTheme.publishedGlow,
                    title: Strings.Profile.Statistics.quizzesCompleted,
                    value: "\(statistics.quizzesCompleted)",
                    subtitle: Strings.Profile.Statistics.monthlyDelta(statistics.quizzesCompletedMonthlyDelta)
                )
                statTile(
                    icon: "target",
                    glow: QuizTheme.draftGlow,
                    title: Strings.Profile.Statistics.accuracy,
                    value: "\(statistics.accuracyPercent)%",
                    subtitle: Strings.Profile.Statistics.accuracyDelta(statistics.accuracyMonthlyDelta)
                )
                statTile(
                    icon: "pencil.and.list.clipboard",
                    glow: QuizTheme.reviewGlow,
                    title: Strings.Profile.Statistics.quizzesCreated,
                    value: "\(statistics.quizzesCreated)",
                    subtitle: Strings.Profile.Statistics.monthlyDelta(statistics.quizzesCreatedMonthlyDelta)
                )
                statTile(
                    icon: "trophy.fill",
                    glow: QuizTheme.publishedGlow,
                    title: Strings.Profile.Statistics.globalRank,
                    value: Strings.Profile.Statistics.rankValue(statistics.globalRank),
                    subtitle: Strings.Profile.Statistics.topPercent(statistics.topPercent)
                )
            }
        }
    }

    private func statTile(
        icon: String,
        glow: Color,
        title: String,
        value: String,
        subtitle: String
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(glow)
                .shadow(color: glow.opacity(0.5), radius: 4)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(glow.opacity(0.9))
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(glow.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: glow.opacity(0.18), radius: 10, x: 0, y: 0)
    }
}
