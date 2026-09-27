import SwiftUI

struct ResultDetailView<ViewModel: ResultDetailViewModel>: View {

    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            QuizListBackgroundView()

            VStack(spacing: 0) {
                navigationBar
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                content
            }
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .task {
            await viewModel.load()
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
                    Text(Strings.ResultsDetail.back)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .foregroundStyle(QuizTheme.draftGlow)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            Text(Strings.ResultsDetail.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer(minLength: 8)

            ShareLink(item: viewModel.shareText) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(QuizTheme.draftGlow)
                    .frame(width: 36, height: 36)
            }
            .disabled(viewModel.shareText.isEmpty)
            .accessibilityLabel(Strings.ResultsDetail.share)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.detail == nil {
            Spacer()
            CometSpinnerView()
            Spacer()
        } else if let detail = viewModel.detail {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ResultDetailSummaryCard(detail: detail)

                        ResultDetailQuestionFilterBar(
                            filter: $viewModel.questionFilter,
                            errorCount: viewModel.errorCount
                        )

                        LazyVStack(spacing: 14) {
                            let questions = viewModel.visibleQuestions
                            ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                                ResultQuestionReviewCard(
                                    question: question,
                                    isExplanationExpanded: viewModel.isExplanationExpanded(question.id),
                                    showsTimelineConnector: index < questions.count - 1,
                                    onToggleExplanation: {
                                        viewModel.toggleExplanation(question.id)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }

                footer
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
            }
        } else {
            Spacer()
            Text(Strings.ResultsDetail.title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
            Spacer()
        }
    }

    private var footer: some View {
        VStack(spacing: 10) {
            outlineButton(
                title: Strings.ResultsDetail.retake,
                systemImage: "arrow.clockwise",
                action: { viewModel.retake() }
            )

            ShareLink(item: viewModel.shareText) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                    Text(Strings.ResultsDetail.shareResult)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.45))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(QuizTheme.publishedGlow, lineWidth: 1.6)
                )
                .shadow(color: QuizTheme.publishedGlow.opacity(0.35), radius: 12, x: 0, y: 0)
            }
            .disabled(viewModel.shareText.isEmpty)
        }
    }

    private func outlineButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.45))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(QuizTheme.publishedGlow, lineWidth: 1.6)
            )
            .shadow(color: QuizTheme.publishedGlow.opacity(0.35), radius: 12, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ResultDetailPreviewContainer()
}

private struct ResultDetailPreviewContainer: View {
    @StateObject private var viewModel = ResultDetailPreviewViewModel()

    var body: some View {
        ResultDetailView(viewModel: viewModel)
    }
}
