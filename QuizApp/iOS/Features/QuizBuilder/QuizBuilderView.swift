import SwiftUI

struct QuizBuilderView<ViewModel: QuizBuilderViewModel>: View {

    @StateObject private var viewModel: ViewModel

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            QuizListBackgroundView()

            if viewModel.currentStep == .preview {
                QuizBuilderPreviewView(viewModel: viewModel)
            } else {
                wizardContent
            }
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .sheet(item: questionEditorBinding) { _ in
            QuizBuilderQuestionEditorView(viewModel: viewModel)
        }
    }

    private var wizardContent: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.horizontal, 16)
                .padding(.top, 8)

            QuizBuilderStepHeader(currentStep: viewModel.currentStep)
                .padding(.horizontal, 8)
                .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let introText {
                        Text(introText)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(QuizTheme.mutedText)
                            .padding(.horizontal, 4)
                    }

                    stepContent
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }

            footer
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
        }
    }

    private var questionEditorBinding: Binding<QuizBuilderQuestionEditorState?> {
        Binding(
            get: { viewModel.questionEditor },
            set: { newValue in
                if newValue == nil {
                    viewModel.cancelQuestionEditor()
                } else {
                    viewModel.questionEditor = newValue
                }
            }
        )
    }

    private var introText: String? {
        switch viewModel.currentStep {
        case .quizDetails:
            return Strings.QuizBuilder.intro
        case .questions:
            return Strings.QuizBuilder.Intro.questions
        case .preview, .publish:
            return nil
        }
    }

    private var navigationBar: some View {
        HStack {
            Button {
                viewModel.goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(QuizTheme.draftGlow)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(Strings.QuizBuilder.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Color.clear
                .frame(width: 36, height: 36)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .quizDetails:
            QuizBuilderDetailsForm(viewModel: viewModel)
        case .questions:
            QuizBuilderQuestionsForm(viewModel: viewModel)
        case .preview:
            EmptyView()
        case .publish:
            placeholderCard(text: Strings.QuizBuilder.Placeholder.publish)
        }
    }

    private func placeholderCard(text: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(QuizTheme.draftGlow)
            Text(text)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 56)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var footer: some View {
        if viewModel.currentStep == .questions {
            questionsFooter
        } else {
            defaultFooter
        }
    }

    private var questionsFooter: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.goBack()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 15, weight: .semibold))
                    Text(Strings.QuizBuilder.Action.back)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .foregroundStyle(QuizTheme.draftGlow)
                .padding(.horizontal, 12)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.45))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(QuizTheme.draftGlow, lineWidth: 1.6)
                )
            }
            .buttonStyle(.plain)

            Button {
                viewModel.goNext()
            } label: {
                HStack(spacing: 8) {
                    Text(Strings.QuizBuilder.Action.nextPreview)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(viewModel.canGoNext ? .white : QuizTheme.mutedText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.45))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            viewModel.canGoNext ? QuizTheme.draftGlow : QuizTheme.mutedText.opacity(0.4),
                            lineWidth: 1.6
                        )
                )
                .shadow(
                    color: viewModel.canGoNext ? QuizTheme.draftGlow.opacity(0.45) : .clear,
                    radius: 12,
                    x: 0,
                    y: 0
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canGoNext)
        }
    }

    private var defaultFooter: some View {
        VStack(spacing: 10) {
            Button {
                viewModel.goNext()
            } label: {
                HStack(spacing: 8) {
                    Text(primaryActionTitle)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    if viewModel.currentStep != .publish {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .foregroundStyle(viewModel.canGoNext ? .white : QuizTheme.mutedText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.45))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            viewModel.canGoNext ? QuizTheme.draftGlow : QuizTheme.mutedText.opacity(0.4),
                            lineWidth: 1.6
                        )
                )
                .shadow(
                    color: viewModel.canGoNext ? QuizTheme.draftGlow.opacity(0.45) : .clear,
                    radius: 12,
                    x: 0,
                    y: 0
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canGoNext)

            if viewModel.currentStep == .quizDetails {
                Label {
                    Text(Strings.QuizBuilder.Footer.note)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(QuizTheme.mutedText)
                } icon: {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(QuizTheme.mutedText)
                }
            }
        }
    }

    private var primaryActionTitle: String {
        viewModel.currentStep == .publish
            ? Strings.QuizBuilder.Action.publish
            : Strings.QuizBuilder.Action.next
    }
}

#Preview {
    QuizBuilderView(viewModel: QuizBuilderViewModelImpl(coordinator: QuizBuilderCoordinatorImpl()))
}
