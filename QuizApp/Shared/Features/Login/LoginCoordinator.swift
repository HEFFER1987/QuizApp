import SwiftUI
import SUICoordinator

protocol LoginCoordinator {

}

class LoginCoordinatorImpl: Coordinator<DefaultRoute>, LoginCoordinator {

    override func start() async {
        let viewModel = LoginViewModelImpl(coordinator: self)

        let route = DefaultRoute(presentationStyle: .push, content: {
            LoginView(viewModel: viewModel)
        })

        await startFlow(route: route)
    }
}