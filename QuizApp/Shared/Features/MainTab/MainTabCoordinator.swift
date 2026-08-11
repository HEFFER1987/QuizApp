import SwiftUI
import SUICoordinator

protocol MainTabCoordinator {
    func showQuizBuilder() async
}

class MainTabCoordinatorImpl: Coordinator<MainTabRoute>, MainTabCoordinator {

    private lazy var quizListCoordinator: QuizListCoordinatorImpl = {
        QuizListCoordinatorImpl(mainTabCoordinator: self)
    }()

    override func start() async {
        await startFlow(route: .main(coordinator: self))
    }

    func showQuizBuilder() async {
        let coordinator = QuizBuilderCoordinatorImpl()
        await navigate(to: coordinator, presentationStyle: .push)
    }

    func makeQuizListViewModel() -> QuizListViewModelImpl {
        QuizListViewModelImpl(coordinator: quizListCoordinator)
    }
}
