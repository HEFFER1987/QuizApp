import SwiftUI

struct ResultsView<ViewModel: ResultsViewModel>: View {

    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView

            if let summary = viewModel.summary {
                ResultsSummaryCard(summary: summary)
            }

            ResultsFilterChips(filter: $viewModel.filter)

            resultsListContent
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .task {
            await viewModel.loadResults()
        }
    }

    private var headerView: some View {
        HStack {
            Text(Strings.ResultsHistory.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Button {
                viewModel.openFilterOptions()
            } label: {
                HexagonIconView(
                    systemName: "line.3.horizontal.decrease",
                    glowColor: QuizTheme.publishedGlow,
                    size: 40,
                    iconSize: 14
                )
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var resultsListContent: some View {
        if viewModel.isLoading && viewModel.results.isEmpty {
            Spacer()
            ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity)
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredResults) { result in
                        ResultCardView(result: result) {
                            viewModel.openResult(result)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    ResultsPreviewContainer()
}

private struct ResultsPreviewContainer: View {
    @StateObject private var viewModel = ResultsPreviewViewModel()

    var body: some View {
        ZStack {
            QuizListBackgroundView()
            ResultsView(viewModel: viewModel)
        }
    }
}
