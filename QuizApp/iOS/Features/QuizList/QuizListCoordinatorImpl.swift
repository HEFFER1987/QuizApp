import Foundation

final class QuizListCoordinatorImpl: QuizListCoordinator {

    private weak var mainTabCoordinator: MainTabCoordinatorImpl?

    init(mainTabCoordinator: MainTabCoordinatorImpl? = nil) {
        self.mainTabCoordinator = mainTabCoordinator
    }

    func showQuizBuilder() async {
        await mainTabCoordinator?.showQuizBuilder()
    }

    func playQuiz(_ quiz: Quiz) async {
        await mainTabCoordinator?.showQuizPlay(quizID: quiz.id)
    }
}
