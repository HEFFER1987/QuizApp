import SwiftUI

struct QuizPlayHeaderView: View {
    let progressText: String
    let progressValue: Double
    let elapsedSeconds: Int
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(QuizTheme.cardFill))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                Text(progressText)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                timerBadge
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)
                    Capsule()
                        .fill(QuizTheme.publishedGlow)
                        .frame(width: max(6, geometry.size.width * progressValue), height: 6)
                        .shadow(color: QuizTheme.publishedGlow.opacity(0.55), radius: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private var timerBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.system(size: 12, weight: .semibold))
            Text(formatTime(elapsedSeconds))
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .foregroundStyle(QuizTheme.draftGlow)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(QuizTheme.draftGlow.opacity(0.12))
        )
        .overlay(
            Capsule()
                .stroke(QuizTheme.draftGlow.opacity(0.45), lineWidth: 1)
        )
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

struct QuizPlayCategoryBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(QuizTheme.publishedGlow)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(QuizTheme.publishedGlow.opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke(QuizTheme.publishedGlow.opacity(0.55), lineWidth: 1)
            )
    }
}

struct QuizPlayCodeSnippetView: View {
    let code: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(code)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.92))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .padding(.trailing, 36)

            Button {
                UIPasteboard.general.string = code
            } label: {
                Image(systemName: "square.on.square")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QuizTheme.publishedGlow.opacity(0.85))
                    .padding(10)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Strings.QuizPlay.copyCode)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(QuizTheme.publishedGlow.opacity(0.25), lineWidth: 1)
        )
    }
}

struct QuizPlayAnswerOptionRow: View {
    let letter: String
    let text: String
    let state: QuizPlayOptionVisualState
    let explanation: String?
    let showsExplanation: Bool

    private var borderColor: Color {
        switch state {
        case .normal:
            return QuizTheme.publishedGlow.opacity(0.35)
        case .selected:
            return QuizTheme.publishedGlow
        case .correct:
            return QuizTheme.publishedGlow
        case .incorrect:
            return QuizTheme.draftGlow
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(borderColor)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(borderColor.opacity(0.85), lineWidth: 1.4)
                    )

                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                trailingIcon
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)

            if showsExplanation, let explanation, !explanation.isEmpty {
                explanationPanel(explanation)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(QuizTheme.cardFill.opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(borderColor.opacity(state == .normal ? 0.35 : 0.9), lineWidth: state == .normal ? 1 : 1.4)
        )
        .shadow(color: borderColor.opacity(state == .selected || state == .correct ? 0.35 : 0), radius: 10)
    }

    @ViewBuilder
    private var trailingIcon: some View {
        switch state {
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(QuizTheme.publishedGlow)
        case .incorrect:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(QuizTheme.draftGlow)
        default:
            EmptyView()
        }
    }

    private func explanationPanel(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .overlay(QuizTheme.draftGlow.opacity(0.35))

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QuizTheme.draftGlow)
                Text(text)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
    }
}

struct QuizPlayHintsPanel: View {
    let hintsRemaining: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.QuizPlay.Hints.title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
                .tracking(1.2)

            HStack(spacing: 10) {
                hintButton(icon: "hexagon.fill", title: Strings.QuizPlay.Hints.fiftyFifty)
                hintButton(icon: "person.3.fill", title: Strings.QuizPlay.Hints.audience)
                hintButton(icon: "clock.arrow.circlepath", title: Strings.QuizPlay.Hints.extraTime)
                Spacer(minLength: 8)
                hintsCounter
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(QuizTheme.cardFill.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func hintButton(icon: String, title: String) -> some View {
        Button {} label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QuizTheme.publishedGlow)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(QuizTheme.publishedGlow.opacity(0.12))
                    )
                    .overlay(
                        Circle()
                            .stroke(QuizTheme.publishedGlow.opacity(0.4), lineWidth: 1)
                    )
                Text(title)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(QuizTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 72)
            }
        }
        .buttonStyle(.plain)
        .disabled(true)
        .opacity(0.95)
    }

    private var hintsCounter: some View {
        VStack(spacing: 4) {
            Text("\(hintsRemaining)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(Strings.QuizPlay.Hints.countLabel)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
        }
        .frame(width: 64, height: 64)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.35))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct QuizPlayPrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(isEnabled ? QuizTheme.publishedGlow : QuizTheme.mutedText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.25))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isEnabled ? QuizTheme.publishedGlow.opacity(0.85) : Color.white.opacity(0.12),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: isEnabled ? QuizTheme.publishedGlow.opacity(0.25) : .clear, radius: 12)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

struct QuizPlaySessionResultView<ViewModel: QuizPlayViewModel>: View {
    let result: QuizPlaySessionResult
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 18) {
            Text(Strings.QuizPlay.Complete.title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
            Text("\(result.scorePercent)%")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("\(result.correctCount) / \(result.totalCount)")
                .foregroundStyle(.white)
            Text(Strings.QuizPlay.Complete.greatJob)
                .foregroundStyle(QuizTheme.publishedGlow)
            HStack(spacing: 20) {
                Label("+\(result.xpEarned) XP", systemImage: "star.fill")
                Label("\(result.coinsEarned)", systemImage: "bitcoinsign.circle")
            }
            .foregroundStyle(.white)
            if result.leveledUp, let level = result.newLevel {
                Text(Strings.QuizPlay.Complete.levelUp(level))
                    .foregroundStyle(QuizTheme.excellentGlow)
            }
            VStack(spacing: 12) {
                QuizPlayPrimaryButton(
                    title: Strings.QuizPlay.Complete.review,
                    isEnabled: true,
                    action: viewModel.reviewAnswers
                )
                QuizPlayPrimaryButton(
                    title: Strings.QuizPlay.Complete.retry,
                    isEnabled: true,
                    action: viewModel.retry
                )
                ShareLink(item: "\(result.quizTitle): \(result.scorePercent)%") {
                    Text(Strings.QuizPlay.Complete.share)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(QuizTheme.publishedGlow)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
