import Foundation
import AuthenticationServices

enum SignUpError: Error {
    case emailEmpty
    case passwordEmpty
    case confirmPasswordEmpty
    case passwordMismatch
    case appleIDCredentialEmpty
    case authentificationService(error: Error)
    case rawNonceEmpty
    case idTokenEmpty
    case firebase(error: Error)
}

protocol SignUpViewModel: ObservableObject {
    var email: String { get set }
    var password: String { get set }
    var confirmPassword: String { get set }

    func signUp()
    func login() async
    func signUpWithApple(result: Result<ASAuthorization, any Error>)
    func signUpWithGoogle()
}

class SignUpViewModelImpl: SignUpViewModel {

    let coordinator: SignUpCoordinator
    private let authManager: AuthManager
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var error: SignUpError?
    @Published var isLoading: Bool = false

    init(
        coordinator: SignUpCoordinator,
        authManager: AuthManager = AuthManagerImp()
    ) {
        self.coordinator = coordinator
        self.authManager = authManager
    }

    func signUp() {
        let email = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.password
        let confirmPassword = self.confirmPassword

        guard !email.isEmpty else { 
            self.error = .emailEmpty
            return
        }
        guard !password.isEmpty, !confirmPassword.isEmpty else {
            self.error = .passwordEmpty
            return
        }
        guard password == confirmPassword else { 
            self.error = .passwordMismatch
            return 
        }
        guard !confirmPassword.isEmpty else { 
            self.error = .confirmPasswordEmpty
            return 
        }
        self.isLoading = true
        defer {
            self.isLoading = false
        }

        Task {
            do {
                _ = try await authManager.signUp(method: .email(email: email, password: password))
            } catch {
                Logger.shared.log("Firebase register failed: \(error)", level: .error)
                self.error = .firebase(error: error)
            }
        }
    }

    func login() {
        Task {
            await coordinator.moveBackToLogin()
        }
    }

    func signUpWithApple(result: Result<ASAuthorization, any Error>) {
        
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
                    _ = try await authManager.signUp(method: .apple(idToken: idTokenString, rawNonce: rawNonceString))
                } catch {
                    Logger.shared.log("Firebase sign up with Apple failed: \(error)", level: .error)
                    self.error = .firebase(error: error)
                }
            }
        case .failure(let error):
            Logger.shared.log("Entire authentification service failed: \(error)", level: .error)
            self.error = .authentificationService(error: error)
        }
    }

    func signUpWithGoogle() {
        // Task {
        //     do {
        //         _ = try await authManager.signUp(method: .google(idToken: idToken, accessToken: accessToken))
        //     } catch {
        //         Logger.shared.log("Firebase sign up with Google failed: \(error)", level: .error)
        //     }
        // }
    }
}
