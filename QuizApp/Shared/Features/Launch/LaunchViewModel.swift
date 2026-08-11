import Foundation

protocol LaunchViewModel: ObservableObject {
    func trippleTap() async
    func startTimer() async
}

class LaunchViewModelImpl: LaunchViewModel {

    let coordinator: LaunchCoordinator

    init (coordinator: LaunchCoordinator) {
        self.coordinator = coordinator
    }

    @MainActor func startTimer() async {
        Task {
            do {
                try await Task.sleep(for: .seconds(3))
                if AppStateManager.shared.authorizationState.isAuthorized {
                    await coordinator.showMainApp()
                } else {
                    await coordinator.showLogin()
                }
            } catch {
                print("Error starting timer: \(error)")
            }
        }
    }

    @MainActor func trippleTap() async {
        await coordinator.showLogs()
    }
}
