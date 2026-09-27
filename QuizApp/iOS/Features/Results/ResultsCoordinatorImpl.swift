import Foundation

final class ResultsCoordinatorImpl: ResultsCoordinator {

    private weak var mainTabCoordinator: MainTabCoordinatorImpl?

    init(mainTabCoordinator: MainTabCoordinatorImpl? = nil) {
        self.mainTabCoordinator = mainTabCoordinator
    }

    func openResult(_ result: QuizResult) {
        Task {
            await mainTabCoordinator?.showResultDetail(result)
        }
    }
}
