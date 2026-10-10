import Foundation

class AuthViewModelBase: ObservableObject {
    let authManager: AuthManager
    let googleSignInProvider: GoogleSignInProviding

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var emailValidationMessage: String?
    @Published var passwordValidationMessage: String?
    @Published var isLoading: Bool = false

    func clearEmailValidation() {
        emailValidationMessage = nil
    }

    func clearPasswordValidation() {
        passwordValidationMessage = nil
    }

    init(
        authManager: AuthManager? = nil,
        googleSignInProvider: GoogleSignInProviding? = nil
    ) {
        self.authManager = authManager ?? AppDependencies.makeAuthManager()
        self.googleSignInProvider = googleSignInProvider ?? AppDependencies.makeGoogleSignInProvider()
    }

    func googleSignInTokens() async throws -> GoogleSignInTokens {
        try await googleSignInProvider.signIn()
    }

    func googleSignUpTokens() async throws -> GoogleSignInTokens {
        try await googleSignInProvider.signIn()
    }
}
