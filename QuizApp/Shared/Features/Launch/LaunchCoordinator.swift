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
//        await navigate(toRoute: .login(coordinator: coordinator))
        await navigate(
            to: coordinator,
            presentationStyle: .custom(transition: .identity, animation: .default, fullScreen: true)
        )
    }

    func showMainApp() async {
        let coordinator = MainTabCoordinatorImpl()
        await navigate(
            to: coordinator,
            presentationStyle: .custom(transition: .identity, animation: .default, fullScreen: true)
        )
    }
}
