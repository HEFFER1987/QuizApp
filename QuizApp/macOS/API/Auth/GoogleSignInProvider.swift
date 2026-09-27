import AppKit
import FirebaseCore
import GoogleSignIn

final class GoogleSignInProvider: GoogleSignInProviding {
    func signIn() async throws -> GoogleSignInTokens {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GoogleSignInError.configurationMissing
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let window = NSApplication.shared.keyWindow ?? NSApplication.shared.windows.first else {
            throw GoogleSignInError.noPresentingContext
        }

        do {
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: window)
            let user = signInResult.user

            guard let idToken = user.idToken?.tokenString, !idToken.isEmpty else {
                throw GoogleSignInError.idTokenEmpty
            }
            let accessToken = user.accessToken.tokenString
            guard !accessToken.isEmpty else {
                throw GoogleSignInError.accessTokenEmpty
            }

            return GoogleSignInTokens(idToken: idToken, accessToken: accessToken)
        } catch let error as GoogleSignInError {
            throw error
        } catch {
            throw GoogleSignInError.underlying(error)
        }
    }
}
