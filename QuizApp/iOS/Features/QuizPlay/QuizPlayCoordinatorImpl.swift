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
        await finishFlow(animated: true)
        await mainTabCoordinator?.showResultDetail(
            QuizResult(
                id: result.sessionID,
                quizTitle: result.quizTitle,
                iconName: result.iconName,
                iconGlow: .blue,
                completedAt: Date(),
                correctCount: result.correctCount,
                totalCount: result.totalCount,
                durationSeconds: result.durationSeconds,
                xpEarned: result.xpEarned,
                scorePercent: result.scorePercent,
                isComposite: false
            )
        )
    }

    func dismiss() async {
        await finishFlow(animated: true)
    }
}
