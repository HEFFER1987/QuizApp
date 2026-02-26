import Combine
import SwiftUI
import SUICoordinator

protocol LogsCoordinator {

}

class LogsCoordinatorImpl: Coordinator<DefaultRoute>, LogsCoordinator {

    override func start() async {
        let viewModel = LogsViewModelImpl(coordinator: self)

        let route = DefaultRoute(presentationStyle: .push, content: {
            LogsView(viewModel: viewModel)
        })

        await startFlow(route: route)
    }
}