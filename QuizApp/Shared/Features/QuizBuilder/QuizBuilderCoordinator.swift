import SwiftUI
import SUICoordinator

protocol QuizBuilderCoordinator {}

class QuizBuilderCoordinatorImpl: Coordinator<DefaultRoute>, QuizBuilderCoordinator {

    override func start() async {
        let viewModel = QuizBuilderViewModelImpl(coordinator: self)
        let route = DefaultRoute(presentationStyle: .push, content: {
            QuizBuilderView(viewModel: viewModel)
        })
        await startFlow(route: route)
    }
}
