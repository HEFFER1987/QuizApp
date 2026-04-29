import Foundation
import FirebaseCore
import FirebaseAuth

enum AuthMethod {
    case email(email: String, password: String)
    case google(idToken: String, accessToken: String)
    case apple(idToken: String, rawNonce: String)
}

protocol AuthManager {
    func signUp(method: AuthMethod) async throws -> String
    func signIn(method: AuthMethod) async throws -> String
}

final class AuthManagerImp: AuthManager {
    private let auth: Auth = Auth.auth()

    func signUp(method: AuthMethod) async throws -> String {
        switch method {
        case .email(let email, let password):
            return try await registerInFirebase(email: email, password: password)
        case .google(let idToken, let accessToken):
            return try await registerInFirebaseWithGoogle(idToken: idToken, accessToken: accessToken)
        case .apple(let idToken, let rawNonce):
            return try await registerInFirebaseWithApple(idToken: idToken, rawNonce: rawNonce)
        }
    }

    func signIn(method: AuthMethod) async throws -> String {
        switch method {
        case .email(let email, let password):
            return try await signInInFirebase(email: email, password: password)
        case .google(let idToken, let accessToken):
            return try await signUpWithGoogleInFirebase(idToken: idToken, accessToken: accessToken)
        case .apple(let idToken, let rawNonce):
            return try await signUpWithAppleInFirebase(idToken: idToken, rawNonce: rawNonce)
        }
    }

    // MARK: - Firebase
    func registerInFirebase(email: String, password: String) async throws -> String {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user.uid
    }

    func signInInFirebase(email: String, password: String) async throws -> String {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user.uid
    }

    // MARK: - Google
    func registerInFirebaseWithGoogle(idToken: String, accessToken: String) async throws -> String {
        try await signUpWithGoogleInFirebase(idToken: idToken, accessToken: accessToken)
    }
    
    func signUpWithGoogleInFirebase(idToken: String, accessToken: String) async throws -> String {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let result = try await auth.signIn(with: credential)
        return result.user.uid
    }

    // MARK: - Apple
    func registerInFirebaseWithApple(idToken: String, rawNonce: String) async throws -> String {
        try await signUpWithAppleInFirebase(idToken: idToken, rawNonce: rawNonce)
    }

    func signUpWithAppleInFirebase(idToken: String, rawNonce: String) async throws -> String {
        let credential = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: rawNonce, fullName: nil)
        let result = try await auth.signIn(with: credential)
        return result.user.uid
    }
}
