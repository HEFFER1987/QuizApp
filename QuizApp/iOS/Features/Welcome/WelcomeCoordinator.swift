import Foundation
import SUICoordinator

protocol WelcomeCoordinator {
    func continueAsGuest() async
    func showLogin() async
    func showMainApp() async
}

final class WelcomeCoordinatorImpl: Coordinator<WelcomeRoute>, WelcomeCoordinator {

    override func start() async {
        await startFlow(route: .main(coordinator: self))
    }

    func continueAsGuest() async {
        AppStateManager.shared.setGuest()
        await showMainApp()
    }

    func showLogin() async {
        let coordinator = LoginCoordinatorImpl()
        await navigate(
            to: coordinator,
            presentationStyle: .platformRootFlow
        )
    }

    func showMainApp() async {
        let coordinator = MainTabCoordinatorImpl()
        await navigate(
            to: coordinator,
            presentationStyle: .platformRootFlow
        )
    }
}
