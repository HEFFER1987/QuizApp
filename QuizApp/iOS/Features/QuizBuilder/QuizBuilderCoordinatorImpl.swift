import SwiftUI
import SUICoordinator

final class QuizBuilderCoordinatorImpl: Coordinator<DefaultRoute>, QuizBuilderCoordinator {

    override func start() async {
        let viewModel = QuizBuilderViewModelImpl(coordinator: self)
        let route = DefaultRoute(presentationStyle: .push, content: {
            QuizBuilderView(viewModel: viewModel)
        })
        await startFlow(route: route)
    }

    func dismiss() async {
        await finishFlow(animated: true)
    }
}
