import SwiftUI
import SUICoordinator

protocol LoginCoordinator {
    func showSignUp() async
    func showMainApp() async
}

class LoginCoordinatorImpl: Coordinator<LoginRoute>, LoginCoordinator {

    override func start() async {
        await startFlow(route: .main(coordinator: self))
    }

    func showSignUp() async {
        let coordinator = SignUpCoordinatorImpl()
        await navigate(to: coordinator, presentationStyle: .push)
    }

    func showMainApp() async {
        let coordinator = MainTabCoordinatorImpl()
        await navigate(to: coordinator, presentationStyle: .fullScreenCover)
    }
}
