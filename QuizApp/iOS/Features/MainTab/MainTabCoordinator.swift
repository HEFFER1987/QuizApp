import SwiftUI
import SUICoordinator

protocol MainTabCoordinator {
    func showQuizBuilder() async
    func showQuizPlay(quizID: String) async
    func showResultDetail(_ result: QuizResult) async
    func showLogin() async
    func showWelcome() async
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
        guard AppStateManager.shared.canAuthorQuizzes else { return }
        let coordinator = QuizBuilderCoordinatorImpl()
        await navigate(to: coordinator, presentationStyle: .push)
    }

    func showLogin() async {
        let coordinator = LoginCoordinatorImpl()
        await navigate(to: coordinator, presentationStyle: .fullScreenCover)
    }

    func showWelcome() async {
        let coordinator = WelcomeCoordinatorImpl()
        await navigate(to: coordinator, presentationStyle: .platformRootFlow)
    }

    func showQuizPlay(quizID: String) async {
        let coordinator = QuizPlayCoordinatorImpl(quizID: quizID, mainTabCoordinator: self)
        await navigate(to: coordinator, presentationStyle: .push)
    }

    func showResultDetail(_ result: QuizResult) async {
        let coordinator = ResultDetailCoordinatorImpl(resultId: result.id, mainTabCoordinator: self)
        await navigate(to: coordinator, presentationStyle: .push)
    }

    func makeQuizListViewModel() -> QuizListViewModelImpl {
        QuizListViewModelImpl(
            coordinator: quizListCoordinator,
            quizRepository: AppDependencies.makeQuizRepository(),
            canAuthorQuizzes: AppStateManager.shared.canAuthorQuizzes
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
            resultsRepository: AppDependencies.makeResultsRepository(),
            isGuestSession: AppStateManager.shared.isGuest
        )
    }
}
