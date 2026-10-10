import Foundation

@MainActor
protocol WelcomeViewModel: ObservableObject {
    func continueAsGuest()
    func createAccount()
}

@MainActor
final class WelcomeViewModelImpl: WelcomeViewModel {

    private let coordinator: WelcomeCoordinator

    init(coordinator: WelcomeCoordinator) {
        self.coordinator = coordinator
    }

    func continueAsGuest() {
        Task {
            await coordinator.continueAsGuest()
        }
    }

    func createAccount() {
        Task {
            await coordinator.showLogin()
        }
    }
}
