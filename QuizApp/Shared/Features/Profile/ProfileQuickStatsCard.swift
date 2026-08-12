import SwiftUI

struct ProfileQuickStatsCard: View {
    let profile: UserProfile

    var body: some View {
        HStack(spacing: 0) {
            streakColumn
            divider
            coinsColumn
            divider
            achievementsColumn
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var streakColumn: some View {
        statColumn(
            icon: "flame.fill",
            glow: QuizTheme.draftGlow,
            title: Strings.Profile.QuickStats.streak,
            value: "\(profile.streakDays)",
            subtitle: Strings.Profile.QuickStats.streakValue
        )
    }

    private var coinsColumn: some View {
        statColumn(
            icon: "bitcoinsign.circle.fill",
            glow: QuizTheme.publishedGlow,
            title: Strings.Profile.QuickStats.coins,
            value: formattedCoins,
            subtitle: nil
        )
    }

    private var achievementsColumn: some View {
        statColumn(
            icon: "shield.lefthalf.filled",
            glow: QuizTheme.reviewGlow,
            title: Strings.Profile.QuickStats.achievements,
            value: "\(profile.achievementsUnlocked) / \(profile.achievementsTotal)",
            subtitle: Strings.Profile.QuickStats.achievementsValue
        )
    }

    private func statColumn(
        icon: String,
        glow: Color,
        title: String,
        value: String,
        subtitle: String?
    ) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(glow)
                .shadow(color: glow.opacity(0.6), radius: 6)

            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(width: 1, height: 64)
    }

    private var formattedCoins: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: profile.coins)) ?? "\(profile.coins)"
    }
}
