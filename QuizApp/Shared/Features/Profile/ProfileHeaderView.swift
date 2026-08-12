import SwiftUI

struct ProfileHeaderView: View {
    let profile: UserProfile
    let onSettingsTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            titleRow
            identityRow
            xpSection
        }
    }

    private var titleRow: some View {
        HStack {
            Text(Strings.Profile.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Button(action: onSettingsTap) {
                HexagonIconView(
                    systemName: "gearshape.fill",
                    glowColor: QuizTheme.publishedGlow,
                    size: 40,
                    iconSize: 14
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var identityRow: some View {
        HStack(alignment: .center, spacing: 14) {
            avatarView

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.displayName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(profile.handle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(QuizTheme.publishedGlow)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(QuizTheme.draftGlow)
                    Text(profile.titleBadge)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(QuizTheme.mutedText)
                }
            }

            Spacer(minLength: 8)

            levelBadge
        }
    }

    private var avatarView: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .stroke(QuizTheme.draftGlow.opacity(0.95), lineWidth: 3)
                    .frame(width: 78, height: 78)
                    .shadow(color: QuizTheme.draftGlow.opacity(0.55), radius: 10, x: 0, y: 0)

                Circle()
                    .fill(QuizTheme.cardFill)
                    .frame(width: 70, height: 70)

                Image(systemName: profile.avatarSystemName)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(QuizTheme.draftGlow)
            }

            Text("\(profile.level)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(
                    HexagonShape()
                        .fill(QuizTheme.draftGlow.opacity(0.35))
                )
                .overlay(
                    HexagonShape()
                        .stroke(QuizTheme.draftGlow, lineWidth: 1.2)
                )
                .shadow(color: QuizTheme.draftGlow.opacity(0.5), radius: 4)
                .offset(x: 4, y: 4)
        }
    }

    private var levelBadge: some View {
        Text(Strings.Profile.level(profile.level))
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .frame(width: 64, height: 64)
            .background(
                HexagonShape()
                    .fill(QuizTheme.publishedGlow.opacity(0.18))
            )
            .overlay(
                HexagonShape()
                    .stroke(QuizTheme.publishedGlow.opacity(0.95), lineWidth: 1.6)
            )
            .shadow(color: QuizTheme.publishedGlow.opacity(0.55), radius: 10, x: 0, y: 0)
    }

    private var xpSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 8)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [QuizTheme.publishedGlow, Color.white.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * profile.xpProgress, height: 8)
                        .shadow(color: QuizTheme.publishedGlow.opacity(0.55), radius: 6)
                }
            }
            .frame(height: 8)

            Text(Strings.Profile.Xp.progress(profile.currentXP, profile.levelXP))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text(Strings.Profile.Xp.remaining(profile.xpRemaining))
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
        }
    }
}
