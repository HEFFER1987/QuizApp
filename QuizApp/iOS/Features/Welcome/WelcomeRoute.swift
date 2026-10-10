import SwiftUI
import SUICoordinator

enum WelcomeRoute: RouteType {
    case main(coordinator: WelcomeCoordinator)

    var presentationStyle: TransitionPresentationStyle {
        .platformRootFlow
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .main(let coordinator):
            ZStack {
                WelcomeBackgroundView()
                WelcomeView(viewModel: WelcomeViewModelImpl(coordinator: coordinator))
            }
        }
    }
}
