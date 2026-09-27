import SwiftUI
import SUICoordinator

enum MainTabRoute: RouteType {

    case main(coordinator: MainTabCoordinatorImpl)

    var presentationStyle: TransitionPresentationStyle {
        .platformRootFlow
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .main(let coordinator):
            MainTabView(
                quizListViewModel: coordinator.makeQuizListViewModel(),
                resultsViewModel: coordinator.makeResultsViewModel(),
                profileViewModel: coordinator.makeProfileViewModel()
            )
        }
    }
}
