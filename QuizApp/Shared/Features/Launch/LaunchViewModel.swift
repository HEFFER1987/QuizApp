import Foundation

#if os(macOS)
enum MacLaunchContent: Equatable {
    case splash
    case hidden
}
#endif

protocol LaunchViewModel: ObservableObject {
    func trippleTap() async
    func startTimer() async
    #if os(macOS)
    @MainActor var macLaunchContent: MacLaunchContent { get }
    @MainActor func hideLaunchContent()
    #endif
}

@MainActor
final class LaunchViewModelImpl: LaunchViewModel {

    let coordinator: LaunchCoordinator

    #if os(macOS)
    @Published private(set) var macLaunchContent: MacLaunchContent = .splash

    func hideLaunchContent() {
        macLaunchContent = .hidden
    }
    #endif

    init(coordinator: LaunchCoordinator) {
        self.coordinator = coordinator
    }

    func startTimer() async {
        do {
            try await Task.sleep(for: .seconds(3))
            if AppStateManager.shared.authorizationState.isAuthorized {
                await coordinator.showMainApp()
                #if os(macOS)
                hideLaunchContent()
                #endif
            } else {
                #if os(macOS)
                let login = await coordinator.makeLoginCoordinator()
                MacLaunchUIState.shared.presentLogin(with: login)
                macLaunchContent = .hidden
                #else
                await coordinator.showLogin()
                #endif
            }
        } catch {
            print("Error starting timer: \(error)")
        }
    }

    func trippleTap() async {
        await coordinator.showLogs()
    }
}
