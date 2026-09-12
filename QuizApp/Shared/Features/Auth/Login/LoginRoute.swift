import SwiftUI
import SUICoordinator

enum LoginRoute: RouteType {

    case main(coordinator: LoginCoordinator)
    case signup(coordinator: SignUpCoordinator)

    var presentationStyle: TransitionPresentationStyle {
        .platformRootFlow
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .main(let coordinator):
            #if os(macOS)
            MacLoginView(viewModel: LoginViewModelImpl(coordinator: coordinator))
            #else
            LoginView(viewModel: LoginViewModelImpl(coordinator: coordinator))
            #endif
        case .signup(let coordinator):
            SignUpView(viewModel: SignUpViewModelImpl(coordinator: coordinator))
        }
    }
}
