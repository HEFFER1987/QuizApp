import Foundation

class AuthViewModelBase: ObservableObject {
    let authManager: AuthManager
    let googleSignInProvider: GoogleSignInProviding

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false

    init(
        authManager: AuthManager = AuthManagerImp(),
        googleSignInProvider: GoogleSignInProviding = GoogleSignInProvider()
    ) {
        self.authManager = authManager
        self.googleSignInProvider = googleSignInProvider
    }

    func googleSignInTokens() async throws -> GoogleSignInTokens {
        try await googleSignInProvider.signIn()
    }

    func googleSignUpTokens() async throws -> GoogleSignInTokens {
        try await googleSignInProvider.signIn()
    }
}
