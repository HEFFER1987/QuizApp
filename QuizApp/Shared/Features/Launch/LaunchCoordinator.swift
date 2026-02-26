import Foundation
import SwiftUI
import SUICoordinator

protocol LaunchCoordinator {
    func showLogs() async
    func showLogin() async
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
        await navigate(toRoute: .login(coordinator: coordinator))
    }
}