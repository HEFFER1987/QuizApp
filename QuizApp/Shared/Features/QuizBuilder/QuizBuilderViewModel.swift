import Foundation

protocol QuizBuilderViewModel: ObservableObject {}

final class QuizBuilderViewModelImpl: QuizBuilderViewModel {
    let coordinator: QuizBuilderCoordinator

    init(coordinator: QuizBuilderCoordinator) {
        self.coordinator = coordinator
    }
}
