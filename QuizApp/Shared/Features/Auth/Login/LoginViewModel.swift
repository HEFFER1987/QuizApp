import Foundation
import AuthenticationServices

enum LoginError: Error {
    case emailEmpty
    case passwordEmpty
    case appleIDCredentialEmpty
    case rawNonceEmpty
    case idTokenEmpty
    case authentificationService(error: Error)
    case firebase(error: Error)
}

protocol LoginViewModel: ObservableObject {
    var email: String { get set }
    var password: String { get set }

    func login()
    func signUp() async
    func loginWithApple(result: Result<ASAuthorization, any Error>)
    func loginWithGoogle()
}

class LoginViewModelImpl: LoginViewModel {

    let coordinator: LoginCoordinator
    private let authManager: AuthManager

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var error: LoginError?
    @Published var isLoading: Bool = false

    init (
        coordinator: LoginCoordinator,
        authManager: AuthManager = AuthManagerImp()
        ) {
        self.coordinator = coordinator
        self.authManager = authManager
    }

    func login() {
        let email = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.password

        guard !email.isEmpty else { 
            self.error = .emailEmpty
            return 
        }
        guard !password.isEmpty else { 
            self.error = .passwordEmpty
            return 
        }
        self.isLoading = true
        defer {
            self.isLoading = false
        }

        Task {
            do {
                _ = try await authManager.signIn(method: .email(email: email, password: password))
            } catch {
                Logger.shared.log("Firebase sign in failed: \(error)", level: .error)
                self.error = .firebase(error: error)
            }
        }   
    }

    @MainActor func signUp() async {
        await coordinator.showSignUp()
    }

    func loginWithApple(result: Result<ASAuthorization, any Error>) {
        defer {
            self.isLoading = false
        }

        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { 
                self.error = .appleIDCredentialEmpty
                return
            }
            guard let idToken = appleIDCredential.identityToken else { 
                self.error = .appleIDCredentialEmpty
                return
            }
            guard let rawNonce = appleIDCredential.authorizationCode else { 
                self.error = .appleIDCredentialEmpty
                return
            }
        

            let idTokenString = String(data: idToken, encoding: .utf8) ?? ""
            let rawNonceString = String(data: rawNonce, encoding: .utf8) ?? ""

            Task {
                do {
                    _ = try await authManager.signIn(method: .apple(idToken: idTokenString, rawNonce: rawNonceString))
                } catch {
                    Logger.shared.log("Firebase sign in with Apple failed: \(error)", level: .error)
                    self.error = .firebase(error: error)
                }
            }
        case .failure(let error):
            Logger.shared.log("Entire authentification service failed: \(error)", level: .error)
            self.error = .authentificationService(error: error)
        }
    }

    func loginWithGoogle() {

    }
}
