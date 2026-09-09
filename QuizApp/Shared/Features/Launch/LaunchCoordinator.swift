import Foundation
import SwiftUI
import SUICoordinator

protocol LaunchCoordinator {
    func showLogs() async
    func showLogin() async
    func showMainApp() async
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
        #else
        let coordinator = MainTabCoordinatorImpl()
        #endif
        await navigate(
            to: coordinator,
            presentationStyle: .platformRootFlow
        )
    }
}
