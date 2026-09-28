import SwiftUI
import SUICoordinator

protocol MainTabCoordinator {
    func showQuizBuilder() async
    func showResultDetail(_ result: QuizResult) async
}

class MainTabCoordinatorImpl: Coordinator<MainTabRoute>, MainTabCoordinator {

    private lazy var quizListCoordinator: QuizListCoordinatorImpl = {
        QuizListCoordinatorImpl(mainTabCoordinator: self)
    }()

    private lazy var resultsCoordinator: ResultsCoordinatorImpl = {
        ResultsCoordinatorImpl(mainTabCoordinator: self)
    }()

    private lazy var profileCoordinator: ProfileCoordinatorImpl = {
        ProfileCoordinatorImpl(mainTabCoordinator: self)
    }()

    override func start() async {
        await startFlow(route: .main(coordinator: self))
    }

    func showQuizBuilder() async {
        let coordinator = QuizBuilderCoordinatorImpl()
        await navigate(to: coordinator, presentationStyle: .push)
    }

    func showResultDetail(_ result: QuizResult) async {
        let coordinator = ResultDetailCoordinatorImpl(resultId: result.id)
        await navigate(to: coordinator, presentationStyle: .push)
    }

    func makeQuizListViewModel() -> QuizListViewModelImpl {
        QuizListViewModelImpl(
            coordinator: quizListCoordinator,
            quizRepository: AppDependencies.makeQuizRepository()
        )
    }

    func makeResultsViewModel() -> ResultsViewModelImpl {
        ResultsViewModelImpl(
            coordinator: resultsCoordinator,
            resultsRepository: AppDependencies.makeResultsRepository()
        )
    }

    func makeProfileViewModel() -> ProfileViewModelImpl {
        ProfileViewModelImpl(
            coordinator: profileCoordinator,
            profileRepository: AppDependencies.makeProfileRepository(),
            quizRepository: AppDependencies.makeQuizRepository(),
            resultsRepository: AppDependencies.makeResultsRepository()
        )
    }
}
