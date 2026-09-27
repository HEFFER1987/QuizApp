import Foundation

protocol ResultDetailCoordinator {
    func dismiss() async
    func retakeQuiz(title: String) async
}
