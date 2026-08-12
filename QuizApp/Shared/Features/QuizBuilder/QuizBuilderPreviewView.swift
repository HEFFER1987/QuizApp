import SwiftUI

struct QuizBuilderPreviewView<ViewModel: QuizBuilderViewModel>: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    QuizBuilderPreviewInfoCard(
                        title: viewModel.title,
                        descriptionText: viewModel.descriptionText,
                        cover: viewModel.selectedCover,
                        questionCount: viewModel.questions.count,
                        estimatedMinutes: viewModel.previewEstimatedMinutes
                    )

                    if let question = viewModel.currentPreviewQuestion {
                        QuizBuilderPreviewQuestionCard(
                            question: question,
                            currentIndex: viewModel.previewQuestionIndex,
                            total: viewModel.questions.count,
                            isBookmarked: viewModel.isCurrentPreviewQuestionBookmarked,
                            isOptionSelected: { viewModel.isPreviewOptionSelected($0) },
                            onSelectOption: { viewModel.selectPreviewOption($0) },
                            onToggleBookmark: { viewModel.togglePreviewBookmark() }
                        )

                        QuizBuilderPreviewNavigationRow(
                            canGoBack: viewModel.previewQuestionIndex > 0,
                            isOnLastQuestion: viewModel.isOnLastPreviewQuestion,
                            onBack: { viewModel.previewGoBack() },
                            onNext: { viewModel.previewGoNext() }
                        )

                        QuizBuilderPreviewNumberStrip(
                            questionCount: viewModel.questions.count,
                            currentIndex: viewModel.previewQuestionIndex,
                            onSelect: { viewModel.goToPreviewQuestion(at: $0) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }

            tipFooter
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
        }
    }

    private var navigationBar: some View {
        HStack(spacing: 8) {
            Button {
                viewModel.goBack()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text(Strings.QuizBuilder.Preview.backToEdit)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .foregroundStyle(QuizTheme.draftGlow)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            Text(Strings.QuizBuilder.Preview.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer(minLength: 8)

            ShareLink(item: viewModel.sharePreviewText) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(QuizTheme.draftGlow)
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel(Strings.QuizBuilder.Preview.share)
        }
    }

    private var tipFooter: some View {
        Label {
            Text(Strings.QuizBuilder.Preview.tip)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
        } icon: {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(QuizTheme.mutedText)
        }
        .labelStyle(.titleAndIcon)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        QuizListBackgroundView()
        QuizBuilderPreviewView(
            viewModel: QuizBuilderViewModelImpl(coordinator: QuizBuilderCoordinatorImpl())
        )
    }
}
