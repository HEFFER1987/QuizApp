import Foundation

enum AuthMethod {
    case email(email: String, password: String)
    case google(idToken: String, accessToken: String)
    case apple(idToken: String, rawNonce: String)
}

enum MockAuthError: Error {
    case socialSignInUnavailable
}

protocol AuthManager {
    func signUp(method: AuthMethod) async throws -> String
    func signIn(method: AuthMethod) async throws -> String
}

struct AuthManagerMock: AuthManager {
    func signUp(method: AuthMethod) async throws -> String {
        try await signIn(method: method)
    }

    func signIn(method: AuthMethod) async throws -> String {
        switch method {
        case .email:
            return AppDependencies.mockUserId
        case .google, .apple:
            throw MockAuthError.socialSignInUnavailable
        }
    }
}
