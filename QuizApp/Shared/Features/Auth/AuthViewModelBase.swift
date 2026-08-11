import Foundation

class AuthViewModelBase: ObservableObject {
    let authManager: AuthManager
    let googleSignInProvider: GoogleSignInProviding
    let presentingViewControllerProvider: PresentingViewControllerProviding

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false

    init(
        authManager: AuthManager = AuthManagerImp(),
        googleSignInProvider: GoogleSignInProviding = GoogleSignInProvider(),
        presentingViewControllerProvider: PresentingViewControllerProviding =
            UIApplicationTopViewControllerProvider()
    ) {
        self.authManager = authManager
        self.googleSignInProvider = googleSignInProvider
        self.presentingViewControllerProvider = presentingViewControllerProvider
    }

    func googleSignInTokens() async throws -> GoogleSignInTokens {
        let presentingViewController = presentingViewControllerProvider.topViewController
        return try await googleSignInProvider.signIn(presentingViewController: presentingViewController)
    }

    func googleSignUpTokens() async throws -> GoogleSignInTokens {
        let presentingViewController = presentingViewControllerProvider.topViewController
        return try await googleSignInProvider.signIn(presentingViewController: presentingViewController)
    }
}
