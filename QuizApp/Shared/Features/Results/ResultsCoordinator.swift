import Foundation

protocol ResultsCoordinator {
    func openResult(_ result: QuizResult)
}

final class ResultsCoordinatorImpl: ResultsCoordinator {

    func openResult(_ result: QuizResult) {
        Logger.shared.log("Result tapped: \(result.quizTitle)", level: .info)
    }
}
