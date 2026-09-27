import Foundation

protocol QuizListCoordinator {
    func showQuizBuilder() async
    func playQuiz(_ quiz: Quiz) async
}

extension QuizListCoordinator {
    func playQuiz(_ quiz: Quiz) async {}
}
