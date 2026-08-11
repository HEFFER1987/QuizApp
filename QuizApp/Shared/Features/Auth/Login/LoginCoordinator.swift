import SwiftUI
import SUICoordinator

protocol LoginCoordinator {
    func showSignUp() async
}

class LoginCoordinatorImpl: Coordinator<LoginRoute>, LoginCoordinator {

    override func start() async {
        await startFlow(route: .main(coordinator: self))
    }

    func showSignUp() async {
        let coordinator = SignUpCoordinatorImpl()
//        await navigate(toRoute: .signup(coordinator: coordinator))
        await navigate(to: coordinator, presentationStyle: .push)
    }
}
