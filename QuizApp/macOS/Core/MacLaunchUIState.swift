import SwiftUI

@MainActor
final class MacLaunchUIState: ObservableObject {
    static let shared = MacLaunchUIState()

    @Published private(set) var loginCoordinator: LoginCoordinatorImpl?

    var isShowingLogin: Bool { loginCoordinator != nil }

    func presentLogin(with coordinator: LoginCoordinatorImpl) {
        loginCoordinator = coordinator
    }

    func dismissLogin() {
        loginCoordinator = nil
    }
}
