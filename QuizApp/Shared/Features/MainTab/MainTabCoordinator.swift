import SwiftUI
import SUICoordinator

protocol MainTabCoordinator {
    func showQuizBuilder() async
}

class MainTabCoordinatorImpl: Coordinator<MainTabRoute>, MainTabCoordinator {

    private lazy var quizListCoordinator: QuizListCoordinatorImpl = {
        QuizListCoordinatorImpl(mainTabCoordinator: self)
    }()

    private lazy var resultsCoordinator: ResultsCoordinatorImpl = {
        ResultsCoordinatorImpl()
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

    func makeResultsViewModel() -> ResultsViewModelImpl {
        ResultsViewModelImpl(coordinator: resultsCoordinator)
    }
}
