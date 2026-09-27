import SwiftUI

struct MainTabView: View {

    @StateObject private var quizListViewModel: QuizListViewModelImpl
    @StateObject private var resultsViewModel: ResultsViewModelImpl
    @State private var selectedTab: MainTabItem = .quizzes

    init(
        quizListViewModel: @autoclosure @escaping () -> QuizListViewModelImpl,
        resultsViewModel: @autoclosure @escaping () -> ResultsViewModelImpl
    ) {
        _quizListViewModel = StateObject(wrappedValue: quizListViewModel())
        _resultsViewModel = StateObject(wrappedValue: resultsViewModel())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundView

            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            MainTabBar(selectedTab: $selectedTab)
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch selectedTab {
        case .quizzes, .results:
            QuizListBackgroundView()
        case .explore, .profile:
            CommonBackgroundView()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .quizzes:
            QuizListView(viewModel: quizListViewModel)
        case .explore:
            PlaceholderTabView(title: Strings.Placeholder.Explore.title)
        case .results:
            ResultsView(viewModel: resultsViewModel)
        case .profile:
            PlaceholderTabView(title: Strings.Placeholder.Profile.title)
        }
    }
}

#Preview {
    ZStack {
        CommonBackgroundView()
        MainTabView(
            quizListViewModel: QuizListViewModelImpl(
                coordinator: QuizListCoordinatorImpl()
            ),
            resultsViewModel: ResultsViewModelImpl(
                coordinator: ResultsCoordinatorImpl()
            )
        )
    }
}
