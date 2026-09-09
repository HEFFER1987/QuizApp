import SwiftUI
import SUICoordinator

enum LaunchRoute: RouteType {

    case main(coordinator: LaunchCoordinator)
    case logs(coordinator: LogsCoordinator)
    case login(coordinator: LoginCoordinator)

    var presentationStyle: TransitionPresentationStyle {
        .platformRootFlow
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

extension TransitionPresentationStyle {
    /// Replaces the current root flow (Launch → Login/Main).
    /// SUICoordinator's fullScreen container is a no-op on macOS.
    static var platformRootFlow: TransitionPresentationStyle {
        #if os(macOS)
        .custom(transition: .identity, animation: .default, fullScreen: false)
        #else
        .custom(transition: .identity, animation: .default, fullScreen: true)
        #endif
    }

    /// Presents a coordinator modally over the auth stack.
    static var platformModalFlow: TransitionPresentationStyle {
        #if os(macOS)
        .custom(transition: .identity, animation: .default, fullScreen: false)
        #else
        .fullScreenCover
        #endif
    }
}
