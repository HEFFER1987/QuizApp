import Combine
import Foundation

enum AuthorizationProvider: String, Codable, CaseIterable {
    case email
    case google
    case apple
}

enum UnauthorizedReason: String, Codable, Equatable {
    case neverSignedIn
    case signedOut
    case sessionExpired
    case tokenRevoked
    case accountDeleted
}

enum UserAuthorizationState: Equatable, Codable {
    case authorized(userId: String, provider: AuthorizationProvider)
    case guest
    case unauthorized(
        previousProvider: AuthorizationProvider?,
        previousUserId: String?,
        reason: UnauthorizedReason
    )

    var isAuthorized: Bool {
        if case .authorized = self {
            return true
        }
        return false
    }

    var isGuest: Bool {
        if case .guest = self {
            return true
        }
        return false
    }

    var isRegisteredUser: Bool {
        isAuthorized
    }

    #if os(iOS)
    var canAccessMainApp: Bool {
        isAuthorized || isGuest
    }
    #endif

    var canAuthorQuizzes: Bool {
        isAuthorized
    }

    var canPublishContent: Bool {
        isAuthorized
    }

    /// Last sign-in method, available in both authorized and unauthorized states.
    var lastAuthorizationProvider: AuthorizationProvider? {
        switch self {
        case .authorized(_, let provider):
            return provider
        case .guest:
            return nil
        case .unauthorized(let previousProvider, _, _):
            return previousProvider
        }
    }

    var userId: String? {
        switch self {
        case .authorized(let userId, _):
            return userId
        case .guest:
            return nil
        case .unauthorized(_, let previousUserId, _):
            return previousUserId
        }
    }
}

@MainActor
final class AppStateManager: ObservableObject {
    static let shared = AppStateManager()

    @Published private(set) var authorizationState: UserAuthorizationState

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.authorizationState = Self.loadState(from: userDefaults)
    }

    func setAuthorized(userId: String, provider: AuthorizationProvider) {
        authorizationState = .authorized(userId: userId, provider: provider)
        persistState()
    }

    func setGuest() {
        authorizationState = .guest
        persistState()
    }

    var isGuest: Bool {
        authorizationState.isGuest
    }

    var isRegisteredUser: Bool {
        authorizationState.isRegisteredUser
    }

    var canAuthorQuizzes: Bool {
        authorizationState.canAuthorQuizzes
    }

    var canPublishContent: Bool {
        authorizationState.canPublishContent
    }

    #if os(iOS)
    var canAccessMainApp: Bool {
        authorizationState.canAccessMainApp
    }
    #endif

    func setUnauthorized(reason: UnauthorizedReason) {
        let previousProvider = authorizationState.lastAuthorizationProvider
        let previousUserId = authorizationState.userId

        authorizationState = .unauthorized(
            previousProvider: previousProvider,
            previousUserId: previousUserId,
            reason: reason
        )
        persistState()
    }

    func clearAuthorizationState() {
        authorizationState = .unauthorized(
            previousProvider: nil,
            previousUserId: nil,
            reason: .neverSignedIn
        )
        userDefaults.removeObject(forKey: Self.stateStorageKey)
    }
}

// MARK: - Storage

private extension AppStateManager {
    static let stateStorageKey = "core.userAuthorizationState"

    func persistState() {
        guard let data = try? JSONEncoder().encode(authorizationState) else {
            return
        }
        userDefaults.set(data, forKey: Self.stateStorageKey)
    }

    static func loadState(from userDefaults: UserDefaults) -> UserAuthorizationState {
        guard
            let data = userDefaults.data(forKey: stateStorageKey),
            let state = try? JSONDecoder().decode(UserAuthorizationState.self, from: data)
        else {
            return .unauthorized(
                previousProvider: nil,
                previousUserId: nil,
                reason: .neverSignedIn
            )
        }
        return state
    }
}
