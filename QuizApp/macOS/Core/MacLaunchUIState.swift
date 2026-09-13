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

    var isShowingAuth: Bool { authScreen != nil }

    func presentLogin(with coordinator: LoginCoordinatorImpl) {
        authScreen = .login(coordinator)
    }

    func presentSignUp(with coordinator: SignUpCoordinatorImpl) {
        authScreen = .signup(coordinator)
    }

    func dismissAuth() {
        authScreen = nil
    }

    func backToLogin() {
        guard case .signup(let signUpCoordinator) = authScreen,
              let loginCoordinator = signUpCoordinator.parent as? LoginCoordinatorImpl else {
            return
        }
        authScreen = .login(loginCoordinator)
    }
}
