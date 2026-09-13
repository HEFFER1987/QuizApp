import SwiftUI

// MARK: - Header

struct MacAuthHeaderBar: View {
    @State private var settings = SettingsRepositoryUserDefaults().load()

    var body: some View {
        HStack {
            logo
            Spacer()
            HStack(spacing: 14) {
                appearanceButton
                languageMenu
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var logo: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkle")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(QuizTheme.publishedGlow)
            Text("QUIZ")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var appearanceButton: some View {
        Button {
            cycleAppearance()
        } label: {
            Image(systemName: appearanceIconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(QuizTheme.mutedText)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .help("Appearance")
    }

    private var languageMenu: some View {
        Menu {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    settings.language = language
                    persistSettings()
                } label: {
                    if settings.language == language {
                        Label(language.shortCode, systemImage: "checkmark")
                    } else {
                        Text(language.shortCode)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(settings.language.shortCode)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(QuizTheme.mutedText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(QuizTheme.cardFill.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .menuStyle(.borderlessButton)
    }

    private var appearanceIconName: String {
        switch settings.appearance {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }

    private func cycleAppearance() {
        let all = AppAppearance.allCases
        guard let index = all.firstIndex(of: settings.appearance) else { return }
        settings.appearance = all[(index + 1) % all.count]
        persistSettings()
    }

    private func persistSettings() {
        SettingsRepositoryUserDefaults().save(settings)
    }
}

private extension AppLanguage {
    var shortCode: String {
        switch self {
        case .english: return "EN"
        case .ukrainian: return "UA"
        case .russian: return "RU"
        }
    }
}

// MARK: - Welcome

struct MacAuthWelcomeTitle: View {
    var body: some View {
        MacAuthSplitTitle(
            title: Strings.Login.Welcome.title,
            highlight: "Back!"
        )
    }
}

struct MacAuthCreateTitle: View {
    var body: some View {
        MacAuthSplitTitle(
            title: Strings.Signup.Create.title,
            highlight: "Account"
        )
    }
}

private struct MacAuthSplitTitle: View {
    let title: String
    let highlight: String

    var body: some View {
        if let range = title.range(of: highlight) {
            let prefix = String(title[..<range.lowerBound])
            let highlighted = String(title[range.lowerBound...])
            HStack(spacing: 0) {
                Text(prefix)
                    .foregroundStyle(.white)
                Text(highlighted)
                    .foregroundStyle(QuizTheme.publishedGlow)
            }
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .shadow(color: QuizTheme.publishedGlow.opacity(0.35), radius: 12, x: 0, y: 0)
        } else {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

struct MacAuthCenterLogo: View {
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 44, weight: .bold))
            .foregroundStyle(
                LinearGradient(
                    colors: [QuizTheme.publishedGlow, QuizTheme.searchGlow],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: QuizTheme.publishedGlow.opacity(0.6), radius: 16, x: 0, y: 0)
            .padding(.bottom, 8)
    }
}

// MARK: - Fields

struct MacGlassTextField: View {
    let placeholder: String
    let systemImage: String
    @Binding var text: String
    var submitLabel: SubmitLabel = .next
    var onSubmit: () -> Void = {}

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(QuizTheme.mutedText)
                .frame(width: 18)
            TextField(placeholder, text: $text)
                .foregroundStyle(.white)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(fieldBackground)
        .overlay(fieldBorder)
        .shadow(color: QuizTheme.searchGlow.opacity(0.35), radius: 8, x: 0, y: 0)
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(QuizTheme.cardFill)
    }

    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(QuizTheme.searchGlow.opacity(0.85), lineWidth: 1)
    }
}

struct MacGlassPasswordField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var submitLabel: SubmitLabel = .go
    var onSubmit: () -> Void = {}

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock")
                .foregroundStyle(QuizTheme.mutedText)
                .frame(width: 18)
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .foregroundStyle(.white)
            .textFieldStyle(.plain)
            .submitLabel(submitLabel)
            .onSubmit(onSubmit)

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundStyle(QuizTheme.mutedText)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                isVisible ? Text(Strings.Login.Password.hide) : Text(Strings.Login.Password.show)
            )
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(fieldBackground)
        .overlay(fieldBorder)
        .shadow(color: QuizTheme.searchGlow.opacity(0.35), radius: 8, x: 0, y: 0)
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(QuizTheme.cardFill)
    }

    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(QuizTheme.searchGlow.opacity(0.85), lineWidth: 1)
    }
}

// MARK: - Buttons

struct MacNeonPrimaryButton: View {
    let title: String
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [QuizTheme.publishedGlow, QuizTheme.searchGlow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: QuizTheme.publishedGlow.opacity(0.55), radius: 14, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

struct MacAuthOutlineButton: View {
    let title: String
    let icon: MacAuthOutlineButtonIcon
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                iconView
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Spacer(minLength: 0)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(QuizTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(QuizTheme.searchGlow.opacity(0.75), lineWidth: 1)
            )
            .shadow(color: QuizTheme.searchGlow.opacity(0.2), radius: 8, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .google:
            Image(asset: Asset.Login.loginGoogle)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        case .apple:
            Image(systemName: "apple.logo")
                .font(.system(size: 18, weight: .medium))
                .frame(width: 20, height: 20)
        }
    }
}

enum MacAuthOutlineButtonIcon {
    case google
    case apple
}

struct MacAuthDivider: View {
    var label: String = Strings.Login.continueWith

    var body: some View {
        HStack(spacing: 12) {
            line
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
            line
        }
        .padding(.vertical, 4)
    }

    private var line: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(height: 1)
    }
}

// MARK: - Error Banner

struct MacAuthFormErrorBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.red.opacity(0.85))
            )
    }
}

// MARK: - Decorations

struct MacAuthDecorationsView: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            decorationIcon("brain.head.profile", size: 36, centerX: width * 0.08, centerY: height * 0.18)
            decorationIcon("book", size: 32, centerX: width * 0.06, centerY: height * 0.42)
            decorationIcon("lightbulb", size: 34, centerX: width * 0.10, centerY: height * 0.72)

            decorationIcon("graduationcap", size: 36, centerX: width * 0.90, centerY: height * 0.16)
            decorationIcon("scroll", size: 32, centerX: width * 0.92, centerY: height * 0.44)
            decorationIcon("target", size: 34, centerX: width * 0.88, centerY: height * 0.74)
        }
        .allowsHitTesting(false)
    }

    private func decorationIcon(
        _ name: String,
        size: CGFloat,
        centerX: CGFloat,
        centerY: CGFloat
    ) -> some View {
        Image(systemName: name)
            .font(.system(size: size, weight: .light))
            .foregroundStyle(QuizTheme.publishedGlow.opacity(0.45))
            .shadow(color: QuizTheme.publishedGlow.opacity(0.5), radius: 12, x: 0, y: 0)
            .position(x: centerX, y: centerY)
    }
}
