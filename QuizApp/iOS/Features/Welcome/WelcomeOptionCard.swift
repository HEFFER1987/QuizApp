import SwiftUI

struct WelcomeOptionCard: View {
    enum Style {
        case guest
        case account

        var accent: Color {
            switch self {
            case .guest: return QuizTheme.searchGlow
            case .account: return QuizTheme.publishedGlow
            }
        }

        var iconSystemName: String {
            switch self {
            case .guest: return "person.fill"
            case .account: return "crown.fill"
            }
        }
    }

    let style: Style
    let title: String
    let subtitle: String
    let badgeIcon: String
    let badgeText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                iconBadge

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(QuizTheme.mutedText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Image(systemName: badgeIcon)
                            .font(.system(size: 11, weight: .semibold))
                        Text(badgeText)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(style.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.35))
                    )
                    .overlay(
                        Capsule()
                            .stroke(style.accent.opacity(0.6), lineWidth: 1)
                    )
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(style.accent)
                    .padding(.top, 4)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(QuizTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(style.accent.opacity(0.75), lineWidth: 1.2)
            )
            .shadow(color: style.accent.opacity(0.25), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(style.accent.opacity(0.2))
                .frame(width: 52, height: 52)
            Circle()
                .stroke(style.accent.opacity(0.85), lineWidth: 1.5)
                .frame(width: 52, height: 52)
            Image(systemName: style.iconSystemName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    ZStack {
        WelcomeBackgroundView()
        WelcomeOptionCard(
            style: .guest,
            title: "Continue as Guest",
            subtitle: "Take quizzes and view your local results.",
            badgeIcon: "eye",
            badgeText: "Limited features",
            action: {}
        )
        .padding()
    }
}
