import SwiftUI

@MainActor
final class MacLaunchUIState: ObservableObject {
    static let shared = MacLaunchUIState()

    enum AuthScreen: Equatable {
        case login(LoginCoordinatorImpl)
        case signup(SignUpCoordinatorImpl)

        static func == (lhs: AuthScreen, rhs: AuthScreen) -> Bool {
            switch (lhs, rhs) {
            case (.login, .login), (.signup, .signup):
                return true
            default:
                return false
            }
        }
    }

    @Published private(set) var authScreen: AuthScreen?
    @Published private(set) var mainCoordinator: MacRootCoordinatorImpl?

    var isShowingAuth: Bool { authScreen != nil }
    var isShowingMain: Bool { mainCoordinator != nil }

    func presentLogin(with coordinator: LoginCoordinatorImpl) {
        authScreen = .login(coordinator)
    }

    func presentSignUp(with coordinator: SignUpCoordinatorImpl) {
        authScreen = .signup(coordinator)
    }

    func dismissAuth() {
        authScreen = nil
    }

    func presentMain(with coordinator: MacRootCoordinatorImpl) {
        dismissAuth()
        mainCoordinator = coordinator
    }

    func backToLogin() {
        guard case .signup(let signUpCoordinator) = authScreen,
              let loginCoordinator = signUpCoordinator.parent as? LoginCoordinatorImpl else {
            return
        }
        authScreen = .login(loginCoordinator)
    }
}
