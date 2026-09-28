import AppKit
#if !MOCK_DATA
import FirebaseCore
#endif
import SwiftUI

final class MacAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if !MOCK_DATA
        FirebaseApp.configure()
        #endif
        AuthSessionResetter.resetLoginSessionIfNeeded()
    }
}
