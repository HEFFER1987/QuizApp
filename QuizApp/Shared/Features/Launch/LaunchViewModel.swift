import Foundation

protocol LaunchViewModel: ObservableObject {
    func trippleTap() async
}

class LaunchViewModelImpl: LaunchViewModel {

    let coordinator: LaunchCoordinator

    init (coordinator: LaunchCoordinator) {
        self.coordinator = coordinator
    }

    @MainActor func trippleTap() async {
        await coordinator.showLogs()
    }
}