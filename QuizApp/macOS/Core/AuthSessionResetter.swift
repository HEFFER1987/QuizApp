#if !MOCK_DATA
import FirebaseAuth
import GoogleSignIn
#endif
import Foundation

enum AuthSessionResetter {
    @MainActor
    static func resetLoginSessionIfNeeded() {
        guard LaunchArguments.shouldResetLogin else { return }

        AppStateManager.shared.clearAuthorizationState()
        #if !MOCK_DATA
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        #endif

        Logger.shared.log("Login session reset via \(LaunchArguments.resetLogin) launch argument", level: .info)
    }
}
