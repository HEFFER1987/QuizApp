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
            LaunchView(coordinator: coordinator)
        case .login(let coordinator):
            #if os(macOS)
            MacLoginView(viewModel: LoginViewModelImpl(coordinator: coordinator))
            #else
            LoginView(viewModel: LoginViewModelImpl(coordinator: coordinator))
            #endif
        case .logs(let coordinator):
            LogsView(viewModel: LogsViewModelImpl(coordinator: coordinator))
        }
    }
}

extension TransitionPresentationStyle {
    /// Replaces the current root flow (Launch → Login/Main) on iOS.
    /// On macOS, root screens are presented at the app window level via `MacLaunchUIState`.
    static var platformRootFlow: TransitionPresentationStyle {
        #if os(macOS)
        .sheet
        #else
        .custom(transition: .identity, animation: .default, fullScreen: true)
        #endif
    }

    /// Presents a coordinator modally over the auth stack.
    static var platformModalFlow: TransitionPresentationStyle {
        #if os(macOS)
        .sheet
        #else
        .fullScreenCover
        #endif
    }
}
