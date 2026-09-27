import Foundation

enum LaunchArguments {
    static let resetLogin = "-resetLogin"

    static var shouldResetLogin: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains(resetLogin)
        #else
        false
        #endif
    }
}
