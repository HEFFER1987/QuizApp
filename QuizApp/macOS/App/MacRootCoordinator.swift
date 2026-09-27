import SwiftUI
import SUICoordinator

protocol MacRootCoordinatorImplProtocol: MacRootCoordinator {}

final class MacRootCoordinatorImpl: Coordinator<MacRootRoute>, MacRootCoordinatorImplProtocol {

    private lazy var rootViewModel: MacRootViewModel = {
        let viewModel = MacRootViewModel()
        viewModel.coordinator = self
        return viewModel
    }()

    override func start() async {
        await startFlow(route: .main(coordinator: self))
    }

    func makeRootViewModel() -> MacRootViewModel {
        rootViewModel
    }

    func showQuizBuilder() async {
        rootViewModel.contentDestination = .quizEditor
        rootViewModel.inspectorMode = .question
        rootViewModel.showQuizDetailsPanel = true
    }

    func showQuizEditor() async {
        await showQuizBuilder()
    }

    func showResultDetail(_ result: QuizResult) async {
        rootViewModel.contentDestination = .resultDetail(result.id)
        rootViewModel.inspectorMode = .profile
    }

    func showQuizPlay(quizID: String) async {
        rootViewModel.contentDestination = .quizPlay(quizID)
        rootViewModel.inspectorMode = .profile
    }

    func showPublicQuizDetail(quizID: String) async {
        rootViewModel.contentDestination = .publicQuizDetail(quizID)
        rootViewModel.inspectorMode = .profile
    }

    func showAchievements() async {
        rootViewModel.contentDestination = .achievements
        rootViewModel.inspectorMode = .profile
    }

    func showSettings() async {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    func dismissEditor() async {
        rootViewModel.contentDestination = .sidebar(.myQuizzes)
        rootViewModel.selectedSidebarItem = .myQuizzes
        rootViewModel.inspectorMode = .profile
    }
}
