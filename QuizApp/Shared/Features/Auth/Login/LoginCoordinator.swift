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
        #if os(macOS)
        if let launchCoordinator = parent as? LaunchCoordinatorImpl {
            await launchCoordinator.showSignUp(from: self)
            return
        }
        #endif
        let coordinator = SignUpCoordinatorImpl()
        await navigate(to: coordinator, presentationStyle: .push)
    }

    func showMainApp() async {
        #if os(macOS)
        if let launchCoordinator = parent as? LaunchCoordinatorImpl {
            await launchCoordinator.showMainApp()
            return
        }
        let coordinator = MacRootCoordinatorImpl()
        await navigate(to: coordinator, presentationStyle: .platformRootFlow)
        #else
        let coordinator = MainTabCoordinatorImpl()
        await navigate(to: coordinator, presentationStyle: .platformModalFlow)
        #endif
    }
}
