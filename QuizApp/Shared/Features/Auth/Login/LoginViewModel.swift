import Foundation
import AuthenticationServices

enum LoginError: Error {
    case emailEmpty
    case emailInvalid
    case passwordEmpty
    case appleIDCredentialEmpty
    case rawNonceEmpty
    case idTokenEmpty
    case accessTokenEmpty
    case googleConfigurationMissing
    case authentificationService(error: Error)
    case firebase(error: Error)
}

protocol LoginViewModel: ObservableObject {
    var email: String { get set }
    var password: String { get set }
    var emailValidationMessage: String? { get }
    var passwordValidationMessage: String? { get }
    var isLoading: Bool { get }
    var error: LoginError? { get }

    func clearEmailValidation()
    func clearPasswordValidation()

    func login()
    func signUp()
    func loginWithApple(result: Result<ASAuthorization, any Error>, rawNonce: String?)
    func loginWithGoogle()
}

final class LoginViewModelImpl: AuthViewModelBase, LoginViewModel {

    let coordinator: LoginCoordinator

    @Published var error: LoginError?

    init(
        coordinator: LoginCoordinator,
        authManager: AuthManager? = nil,
        googleSignInProvider: GoogleSignInProviding? = nil
    ) {
        self.coordinator = coordinator
        super.init(
            authManager: authManager,
            googleSignInProvider: googleSignInProvider
        )
    }

    func login() {
        let email = AuthCredentialsValidator.normalizedEmail(self.email)
        let password = self.password
        let validation = AuthCredentialsValidator.validateLogin(email: self.email, password: password)
        emailValidationMessage = validation.email
        passwordValidationMessage = validation.password

        guard validation.isValid else {
            self.error = AuthCredentialsValidator.loginError(email: self.email, password: password)
            return
        }

        Task { @MainActor in
            guard !isLoading else { return }
            isLoading = true
            error = nil
            defer { isLoading = false }

            do {
                let userId = try await authManager.signIn(method: .email(email: email, password: password))
                await handleAuthSuccess(userId: userId, provider: .email)
            } catch {
                Logger.shared.log("Firebase sign in failed: \(error)", level: .error)
                self.error = .firebase(error: error)
            }
        }
    }

    func signUp() {
        Task { @MainActor in
            await coordinator.showSignUp()
        }
    }

    func loginWithApple(result: Result<ASAuthorization, any Error>, rawNonce: String?) {
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
                    let userId = try await authManager.signIn(
                        method: .apple(idToken: idTokenString, rawNonce: rawNonce)
                    )
                    await handleAuthSuccess(userId: userId, provider: .apple)
                } catch {
                    Logger.shared.log("Firebase sign in with Apple failed: \(error)", level: .error)
                    await MainActor.run { self.error = .firebase(error: error) }
                }
            }
        case .failure(let error):
            Logger.shared.log("Entire authentification service failed: \(error)", level: .error)
            self.error = .authentificationService(error: error)
        }
    }

    func loginWithGoogle() {
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
                let tokens = try await googleSignInTokens()
                let userId = try await authManager.signIn(
                    method: .google(idToken: tokens.idToken, accessToken: tokens.accessToken)
                )
                await handleAuthSuccess(userId: userId, provider: .google)
            } catch let googleError as GoogleSignInError {
                Logger.shared.log("Google sign-in failed: \(googleError)", level: .error)
                await MainActor.run { self.error = googleError.toLoginError }
            } catch let loginError as LoginError {
                Logger.shared.log("Login with Google failed: \(loginError)", level: .error)
                await MainActor.run { self.error = loginError }
            } catch {
                Logger.shared.log("Login with Google failed: \(error)", level: .error)
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

extension LoginError {
    var userMessage: String {
        switch self {
        case .emailEmpty:
            return Strings.Auth.Validation.Email.empty
        case .emailInvalid:
            return Strings.Auth.Validation.Email.invalid
        case .passwordEmpty:
            return Strings.Auth.Validation.Password.empty
        case .appleIDCredentialEmpty, .rawNonceEmpty, .idTokenEmpty:
            return "Apple sign in failed. Please try again."
        case .accessTokenEmpty:
            return "Google sign in failed. Please try again."
        case .googleConfigurationMissing:
            return "Google sign in is not configured."
        case .authentificationService(let error):
            return error.localizedDescription
        case .firebase(let error):
            let nsError = error as NSError
            if nsError.code == 17995 {
                return "Keychain access failed. Rebuild the app with code signing enabled."
            }
            if nsError.code == 17004 {
                return "Invalid email or password. Check your credentials or create a new account via Sign Up."
            }
            return error.localizedDescription
        }
    }
}

private extension GoogleSignInError {
    var toLoginError: LoginError {
        switch self {
        case .configurationMissing:
            return .googleConfigurationMissing
        case .noPresentingContext:
            return .authentificationService(error: self)
        case .idTokenEmpty:
            return .idTokenEmpty
        case .accessTokenEmpty:
            return .accessTokenEmpty
        case .underlying(let error):
            return .authentificationService(error: error)
        }
    }
}
