import SwiftUI
import SUICoordinator

enum LaunchRoute: RouteType {

    case main(coordinator: LaunchCoordinator)
    case logs(coordinator: LogsCoordinator)
    case login(coordinator: LoginCoordinator)

    var presentationStyle: TransitionPresentationStyle {
        .custom(transition: .identity, animation: .default, fullScreen: true)
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .main(let coordinator):
            LaunchView(viewModel: LaunchViewModelImpl(coordinator: coordinator))
        case .login(let coordinator):
            LoginView(viewModel: LoginViewModelImpl(coordinator: coordinator))
        case .logs(let coordinator):
            LogsView(viewModel: LogsViewModelImpl(coordinator: coordinator))
        }
    }
}
