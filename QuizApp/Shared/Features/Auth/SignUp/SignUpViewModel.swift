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
    func login()
    func signUpWithApple(result: Result<ASAuthorization, any Error>, rawNonce: String?)
    func signUpWithGoogle()
}

final class SignUpViewModelImpl: AuthViewModelBase, SignUpViewModel {

    let coordinator: SignUpCoordinator

    @Published var confirmPassword: String = ""
    @Published var error: SignUpError?

    init(
        coordinator: SignUpCoordinator,
        authManager: AuthManager = AuthManagerImp(),
        googleSignInProvider: GoogleSignInProviding = GoogleSignInProvider(),
        presentingViewControllerProvider: PresentingViewControllerProviding =
            UIApplicationTopViewControllerProvider()
    ) {
        self.coordinator = coordinator
        super.init(
            authManager: authManager,
            googleSignInProvider: googleSignInProvider,
            presentingViewControllerProvider: presentingViewControllerProvider
        )
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
                let userId = try await authManager.signUp(method: .email(email: email, password: password))
                await handleAuthSuccess(userId: userId, provider: .email)
            } catch {
                Logger.shared.log("Firebase register failed: \(error)", level: .error)
                self.error = .firebase(error: error)
            }
        }
    }

    func login() {
        Task { @MainActor in
            await coordinator.moveBackToLogin()
        }
    }

    func signUpWithApple(result: Result<ASAuthorization, any Error>, rawNonce: String?) {
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
            guard let rawNonce else {
                self.error = .rawNonceEmpty
                return
            }
            guard let idTokenString = String(data: idToken, encoding: .utf8) else {
                self.error = .idTokenEmpty
                return
            }

            Task {
                do {
                    let userId = try await authManager.signUp(
                        method: .apple(idToken: idTokenString, rawNonce: rawNonce)
                    )
                    await handleAuthSuccess(userId: userId, provider: .apple)
                } catch {
                    Logger.shared.log("Firebase sign up with Apple failed: \(error)", level: .error)
                    await MainActor.run { self.error = .firebase(error: error) }
                }
            }
        case .failure(let error):
            Logger.shared.log("Entire authentification service failed: \(error)", level: .error)
            self.error = .authentificationService(error: error)
        }
    }

    func signUpWithGoogle() {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.error = nil
            }
            defer {
                Task { @MainActor in
                    self.isLoading = false
                }
            }

            do {
                let tokens = try await googleSignUpTokens()
                let userId = try await authManager.signUp(
                    method: .google(idToken: tokens.idToken, accessToken: tokens.accessToken)
                )
                await handleAuthSuccess(userId: userId, provider: .google)
            } catch let googleError as GoogleSignInError {
                Logger.shared.log("Google sign-up failed: \(googleError)", level: .error)
                await MainActor.run { self.error = googleError.toSignUpError }
            } catch {
                Logger.shared.log("Sign up with Google failed: \(error)", level: .error)
                await MainActor.run { self.error = .firebase(error: error) }
            }
        }
    }

    @MainActor
    private func handleAuthSuccess(userId: String, provider: AuthorizationProvider) async {
        AppStateManager.shared.setAuthorized(userId: userId, provider: provider)
        await coordinator.showMainApp()
    }
}

private extension GoogleSignInError {
    var toSignUpError: SignUpError {
        switch self {
        case .configurationMissing:
            return .authentificationService(error: self)
        case .noPresentingViewController:
            return .authentificationService(error: self)
        case .idTokenEmpty:
            return .idTokenEmpty
        case .accessTokenEmpty:
            return .authentificationService(error: self)
        case .underlying(let error):
            return .authentificationService(error: error)
        }
    }
}
