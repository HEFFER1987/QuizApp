import SwiftUI
import SUICoordinator

protocol QuizListCoordinator {
    func showQuizBuilder() async
    func playQuiz(_ quiz: Quiz) async
}

extension QuizListCoordinator {
    func playQuiz(_ quiz: Quiz) async {}
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
