import SwiftUI

struct ProfileAchievementsSection: View {
    let achievements: [ProfileAchievement]
    let onSeeAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Strings.Profile.Achievements.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                Button(action: onSeeAll) {
                    HStack(spacing: 4) {
                        Text(Strings.Profile.Achievements.seeAll)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(QuizTheme.publishedGlow)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(achievements) { achievement in
                        achievementItem(achievement)
                    }
                }
                .padding(.vertical, 4)
            }

            Capsule()
                .fill(QuizTheme.publishedGlow.opacity(0.55))
                .frame(width: 48, height: 3)
                .frame(maxWidth: .infinity)
                .shadow(color: QuizTheme.publishedGlow.opacity(0.45), radius: 4)
        }
    }

    private func achievementItem(_ achievement: ProfileAchievement) -> some View {
        let glow = achievement.isLocked
            ? QuizTheme.mutedText
            : QuizTheme.glowColor(for: achievement.glow.resultIconGlow)

        return VStack(spacing: 8) {
            ZStack {
                HexagonShape()
                    .fill(glow.opacity(achievement.isLocked ? 0.08 : 0.16))
                    .frame(width: 56, height: 56)

                HexagonShape()
                    .stroke(glow.opacity(achievement.isLocked ? 0.35 : 0.9), lineWidth: 1.4)
                    .frame(width: 56, height: 56)
                    .shadow(color: achievement.isLocked ? .clear : glow.opacity(0.5), radius: 8)

                if let iconText = achievement.iconText {
                    Text(iconText)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(glow)
                } else if let iconName = achievement.iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(glow)
                }
            }

            Text(achievement.title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(achievement.isLocked ? QuizTheme.mutedText : .white)
                .lineLimit(1)
                .frame(width: 72)
                .multilineTextAlignment(.center)
        }
    }
}
