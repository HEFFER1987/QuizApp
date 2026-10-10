import SwiftUI
import SUICoordinator

final class QuizPlayCoordinatorImpl: Coordinator<DefaultRoute>, QuizPlayCoordinator {

    private let quizID: String
    private weak var mainTabCoordinator: MainTabCoordinatorImpl?

    init(quizID: String, mainTabCoordinator: MainTabCoordinatorImpl? = nil) {
        self.quizID = quizID
        self.mainTabCoordinator = mainTabCoordinator
        super.init()
    }

    override func start() async {
        let viewModel = QuizPlayViewModelImpl(
            quizID: quizID,
            coordinator: self,
            repository: AppDependencies.makeQuizPlayRepository()
        )
        let route = DefaultRoute(presentationStyle: .push, content: {
            QuizPlayView(viewModel: viewModel)
        })
        await startFlow(route: route)
    }

    func showSessionResult(_ result: QuizPlaySessionResult) async {
        let quizResult = result.makeQuizResult()
        if AppStateManager.shared.isGuest {
            GuestProgressStore.shared.append(quizResult)
        }
        await finishFlow(animated: true)
        await mainTabCoordinator?.showResultDetail(quizResult)
    }

    func dismiss() async {
        await finishFlow(animated: true)
    }
}
