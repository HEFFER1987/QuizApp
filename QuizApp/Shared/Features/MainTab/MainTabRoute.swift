import SwiftUI
import SUICoordinator

enum MainTabRoute: RouteType {

    case main(coordinator: MainTabCoordinatorImpl)

    var presentationStyle: TransitionPresentationStyle {
        .custom(transition: .identity, animation: .default, fullScreen: true)
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .main(let coordinator):
            MainTabView(
                quizListViewModel: coordinator.makeQuizListViewModel(),
                resultsViewModel: coordinator.makeResultsViewModel()
            )
        }
    }
}
