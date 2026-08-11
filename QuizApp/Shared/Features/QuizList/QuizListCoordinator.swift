import SwiftUI
import SUICoordinator

protocol QuizListCoordinator {
    func showQuizBuilder() async
}

class QuizListCoordinatorImpl: QuizListCoordinator {

    private weak var mainTabCoordinator: MainTabCoordinatorImpl?

    init(mainTabCoordinator: MainTabCoordinatorImpl? = nil) {
        self.mainTabCoordinator = mainTabCoordinator
    }

    func showQuizBuilder() async {
        await mainTabCoordinator?.showQuizBuilder()
    }
}
