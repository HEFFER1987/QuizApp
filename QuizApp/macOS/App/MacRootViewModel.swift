import Foundation

@MainActor
protocol MacRootCoordinator: AnyObject {
    func showQuizBuilder() async
    func showQuizEditor() async
    func showResultDetail(_ result: QuizResult) async
    func showQuizPlay(quizID: String) async
    func showPublicQuizDetail(quizID: String) async
    func showAchievements() async
    func showSettings() async
    func dismissEditor() async
}

@MainActor
final class MacRootViewModel: ObservableObject {
    weak var coordinator: MacRootCoordinator?

    @Published var selectedSidebarItem: MacSidebarItem = .myQuizzes
    @Published var contentDestination: MacContentDestination = .sidebar(.myQuizzes)
    @Published var inspectorMode: MacInspectorMode = .profile
    @Published var isOffline: Bool = false
    @Published var showQuizDetailsPanel: Bool = false
    @Published var showPublishPanel: Bool = false
    @Published var showPreviewWindow: Bool = false

    let quizListViewModel: QuizListViewModelImpl
    let resultsViewModel: ResultsViewModelImpl
    let profileViewModel: ProfileViewModelImpl
    let exploreViewModel: ExploreViewModelImpl
    let settingsViewModel: SettingsViewModelImpl
    let quizBuilderViewModel: QuizBuilderViewModelImpl
    let quizPublishViewModel: QuizPublishViewModelImpl

    init(coordinator: MacRootCoordinator? = nil) {
        self.coordinator = coordinator
        self.quizListViewModel = QuizListViewModelImpl(
            coordinator: MacQuizListCoordinatorImpl(macRootCoordinator: coordinator)
        )
        self.resultsViewModel = ResultsViewModelImpl(
            coordinator: MacResultsCoordinatorImpl(macRootCoordinator: coordinator)
        )
        self.profileViewModel = ProfileViewModelImpl(
            coordinator: MacProfileCoordinatorImpl(macRootCoordinator: coordinator)
        )
        self.exploreViewModel = ExploreViewModelImpl(
            coordinator: ExploreCoordinatorImpl(macRootCoordinator: coordinator)
        )
        self.settingsViewModel = SettingsViewModelImpl()
        self.quizBuilderViewModel = QuizBuilderViewModelImpl(
            coordinator: MacQuizBuilderCoordinatorImpl(macRootCoordinator: coordinator)
        )
        self.quizPublishViewModel = QuizPublishViewModelImpl()
    }

    func selectSidebar(_ item: MacSidebarItem) {
        selectedSidebarItem = item
        contentDestination = .sidebar(item)
        inspectorMode = .profile
    }

    func openSettings() {
        Task {
            await coordinator?.showSettings()
        }
    }

    func makeQuizPlayViewModel(quizID: String) -> QuizPlayViewModelImpl {
        QuizPlayViewModelImpl(
            quizID: quizID,
            coordinator: MacQuizPlayCoordinatorImpl(macRootCoordinator: coordinator)
        )
    }

    func makeResultDetailViewModel(resultID: String) -> ResultDetailViewModelImpl {
        ResultDetailViewModelImpl(
            resultId: resultID,
            coordinator: MacResultDetailCoordinatorImpl(
                resultId: resultID,
                macRootCoordinator: coordinator
            )
        )
    }
}
