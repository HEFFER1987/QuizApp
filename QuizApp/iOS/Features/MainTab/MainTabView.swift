import SwiftUI

struct MainTabView: View {

    @StateObject private var quizListViewModel: QuizListViewModelImpl
    @StateObject private var resultsViewModel: ResultsViewModelImpl
    @StateObject private var profileViewModel: ProfileViewModelImpl
    @State private var selectedTab: MainTabItem = .quizzes

    init(
        quizListViewModel: @autoclosure @escaping () -> QuizListViewModelImpl,
        resultsViewModel: @autoclosure @escaping () -> ResultsViewModelImpl,
        profileViewModel: @autoclosure @escaping () -> ProfileViewModelImpl
    ) {
        _quizListViewModel = StateObject(wrappedValue: quizListViewModel())
        _resultsViewModel = StateObject(wrappedValue: resultsViewModel())
        _profileViewModel = StateObject(wrappedValue: profileViewModel())
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
        case .quizzes, .results, .profile:
            QuizListBackgroundView()
        case .explore:
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
            ProfileView(viewModel: profileViewModel)
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
            ),
            profileViewModel: ProfileViewModelImpl(
                coordinator: ProfileCoordinatorImpl()
            )
        )
    }
}
