import SwiftUI
import SUICoordinator

final class ResultDetailCoordinatorImpl: Coordinator<DefaultRoute>, ResultDetailCoordinator {

    private let resultId: String
    private weak var mainTabCoordinator: MainTabCoordinatorImpl?

    init(resultId: String, mainTabCoordinator: MainTabCoordinatorImpl? = nil) {
        self.resultId = resultId
        self.mainTabCoordinator = mainTabCoordinator
        super.init()
    }

    override func start() async {
        let viewModel = ResultDetailViewModelImpl(
            resultId: resultId,
            coordinator: self,
            resultsRepository: AppDependencies.makeResultsRepository()
        )
        let route = DefaultRoute(presentationStyle: .push, content: {
            ResultDetailView(viewModel: viewModel)
        })
        await startFlow(route: route)
    }

    func dismiss() async {
        await finishFlow(animated: true)
    }

    func retakeQuiz(title: String) async {
        await mainTabCoordinator?.showQuizPlay(quizID: resultId)
    }
}
