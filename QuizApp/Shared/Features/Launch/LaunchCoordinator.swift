import Foundation
import SwiftUI
import SUICoordinator

protocol LaunchCoordinator {
    func showLogs() async
    func showLogin() async
    func showMainApp() async
    #if os(macOS)
    func makeLoginCoordinator() async -> LoginCoordinatorImpl
    func showSignUp(from loginCoordinator: LoginCoordinatorImpl) async
    #endif
}

class LaunchCoordinatorImpl: Coordinator<LaunchRoute>, LaunchCoordinator {

    override func start() async {
        await startFlow(route: .main(coordinator: self))
    }

    func showLogs() async {
        let coordinator = LogsCoordinatorImpl()
        await navigate(toRoute: .logs(coordinator: coordinator))
    }

    func showLogin() async {
        let coordinator = LoginCoordinatorImpl()
        await navigate(
            to: coordinator,
            presentationStyle: .platformRootFlow
        )
    }

    func showMainApp() async {
        #if os(macOS)
        let coordinator = MacRootCoordinatorImpl()
        await coordinator.start()
        await MainActor.run {
            MacLaunchUIState.shared.presentMain(with: coordinator)
        }
        #else
        let coordinator = MainTabCoordinatorImpl()
        await navigate(
            to: coordinator,
            presentationStyle: .platformRootFlow
        )
        #endif
    }

    #if os(macOS)
    func makeLoginCoordinator() async -> LoginCoordinatorImpl {
        let coordinator = LoginCoordinatorImpl()
        coordinator.parent = self
        children.append(coordinator)
        // macOS presents MacLoginView at app window level via MacLaunchUIState.
        // Starting the login flow here would open a sheet with a second MacLoginView
        // that collapses to decorations-only and covers the app-level login UI.
        return coordinator
    }

    func showSignUp(from loginCoordinator: LoginCoordinatorImpl) async {
        let coordinator = SignUpCoordinatorImpl()
        loginCoordinator.children.append(coordinator)
        coordinator.parent = loginCoordinator
        MacLaunchUIState.shared.presentSignUp(with: coordinator)
    }
    #endif
}
