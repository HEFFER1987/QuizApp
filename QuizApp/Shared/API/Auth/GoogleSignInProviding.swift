import Foundation

struct GoogleSignInTokens {
    let idToken: String
    let accessToken: String
}

enum GoogleSignInError: Error {
    case configurationMissing
    case noPresentingContext
    case idTokenEmpty
    case accessTokenEmpty
    case underlying(Error)
}

protocol GoogleSignInProviding {
    func signIn() async throws -> GoogleSignInTokens
}
