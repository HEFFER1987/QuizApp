import SwiftUI

struct MainTabView: View {

    @StateObject private var quizListViewModel: QuizListViewModelImpl
    @State private var selectedTab: MainTabItem = .quizzes

    init(quizListViewModel: @autoclosure @escaping () -> QuizListViewModelImpl) {
        _quizListViewModel = StateObject(wrappedValue: quizListViewModel())
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
        if selectedTab == .quizzes {
            QuizListBackgroundView()
        } else {
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
            PlaceholderTabView(title: Strings.Placeholder.Results.title)
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
            )
        )
    }
}
