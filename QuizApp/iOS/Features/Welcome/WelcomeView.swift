import SwiftUI

struct WelcomeView<ViewModel: WelcomeViewModel>: View {

    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                logoSection
                headlineSection
                cardsSection
                featuresFooter
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
    }

    private var logoSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Image(systemName: "sparkle")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [QuizTheme.searchGlow, QuizTheme.publishedGlow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "circle.dotted")
                    .font(.system(size: 56, weight: .ultraLight))
                    .foregroundStyle(QuizTheme.searchGlow.opacity(0.5))
            }
            .frame(height: 64)

            Text(Strings.Welcome.brand)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .tracking(6)
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var headlineSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                Text(Strings.Welcome.titlePrefix)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(Strings.Welcome.titleAccent)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [QuizTheme.searchGlow, QuizTheme.publishedGlow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .multilineTextAlignment(.center)

            Text(Strings.Welcome.subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }

    private var cardsSection: some View {
        VStack(spacing: 14) {
            WelcomeOptionCard(
                style: .guest,
                title: Strings.Welcome.Guest.title,
                subtitle: Strings.Welcome.Guest.subtitle,
                badgeIcon: "eye",
                badgeText: Strings.Welcome.Guest.badge,
                action: viewModel.continueAsGuest
            )

            WelcomeOptionCard(
                style: .account,
                title: Strings.Welcome.Account.title,
                subtitle: Strings.Welcome.Account.subtitle,
                badgeIcon: "star.fill",
                badgeText: Strings.Welcome.Account.badge,
                action: viewModel.createAccount
            )
        }
    }

    private var featuresFooter: some View {
        HStack(alignment: .top, spacing: 0) {
            featureItem(icon: "book.fill", text: Strings.Welcome.Feature.takeQuizzes)
            divider
            featureItem(icon: "chart.bar.fill", text: Strings.Welcome.Feature.trackProgress)
            divider
            featureItem(icon: "paperplane.fill", text: Strings.Welcome.Feature.createShare)
        }
        .padding(.top, 8)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(width: 1, height: 44)
    }

    private func featureItem(icon: String, text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(QuizTheme.searchGlow)
            Text(text)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Welcome screen background (planet horizon) — matches the welcome design mockup.
struct WelcomeBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            Image(asset: Asset.quizListBackground)
                .resizable()
                .scaledToFill()
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .top
                )
                .clipped()
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .background(Color.black)
    }
}

#Preview {
    ZStack {
        WelcomeBackgroundView()
        WelcomeView(viewModel: WelcomeViewModelImpl(coordinator: WelcomePreviewCoordinator()))
    }
}

private final class WelcomePreviewCoordinator: WelcomeCoordinator {
    func continueAsGuest() async {}
    func showLogin() async {}
    func showMainApp() async {}
}
