import SwiftUI
import SUICoordinator

enum LoginRoute: RouteType {

    case main(coordinator: LoginCoordinator)
    case signup(coordinator: SignUpCoordinator)

    var presentationStyle: TransitionPresentationStyle {
        .custom(transition: .identity, animation: .default, fullScreen: true)
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .main(let coordinator):
            LoginView(viewModel: LoginViewModelImpl(coordinator: coordinator))
        case .signup(let coordinator):
            SignUpView(viewModel: SignUpViewModelImpl(coordinator: coordinator))
        }
    }
}
