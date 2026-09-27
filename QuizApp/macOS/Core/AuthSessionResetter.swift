import FirebaseAuth
import Foundation
import GoogleSignIn

enum AuthSessionResetter {
    @MainActor
    static func resetLoginSessionIfNeeded() {
        guard LaunchArguments.shouldResetLogin else { return }

        AppStateManager.shared.clearAuthorizationState()
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()

        Logger.shared.log("Login session reset via \(LaunchArguments.resetLogin) launch argument", level: .info)
    }
}
