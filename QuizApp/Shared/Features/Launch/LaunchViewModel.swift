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
            #if MOCK_DATA
            if !AppStateManager.shared.authorizationState.isAuthorized {
                AppStateManager.shared.setAuthorized(
                    userId: AppDependencies.mockUserId,
                    provider: .email
                )
            }
            await coordinator.showMainApp()
            #if os(macOS)
            hideLaunchContent()
            #endif
            #else
            #if os(iOS)
            if AppStateManager.shared.canAccessMainApp {
                await coordinator.showMainApp()
            } else {
                await coordinator.showWelcome()
            }
            #else
            if AppStateManager.shared.authorizationState.isAuthorized {
                await coordinator.showMainApp()
                hideLaunchContent()
            } else {
                let login = await coordinator.makeLoginCoordinator()
                MacLaunchUIState.shared.presentLogin(with: login)
                macLaunchContent = .hidden
            }
            #endif
            #endif
        } catch {
            print("Error starting timer: \(error)")
        }
    }

    func trippleTap() async {
        await coordinator.showLogs()
    }
}
