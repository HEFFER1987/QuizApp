import Foundation
import Testing
@testable import QuizApp_iOS

@MainActor
struct ProfileSignOutTests {

    @Test func signOutClearsAuthorizationAndNotifiesCoordinator() {
        AppStateManager.shared.setAuthorized(userId: "user-1", provider: .email)

        let coordinator = ProfileCoordinatorSignOutSpy()
        let viewModel = ProfileViewModelImpl(
            coordinator: coordinator,
            isGuestSession: false
        )

        viewModel.signOut()

        let state = AppStateManager.shared.authorizationState
        guard case .unauthorized(_, _, let reason) = state else {
            Issue.record("Expected unauthorized state after sign out")
            return
        }
        #expect(reason == .signedOut)
        #expect(!AppStateManager.shared.isRegisteredUser)
        #expect(coordinator.signOutCallCount == 1)
    }

    @Test func signOutDoesNothingForGuest() {
        let coordinator = ProfileCoordinatorSignOutSpy()
        let viewModel = ProfileViewModelImpl(
            coordinator: coordinator,
            isGuestSession: true
        )

        viewModel.signOut()

        #expect(coordinator.signOutCallCount == 0)
    }
}

private final class ProfileCoordinatorSignOutSpy: ProfileCoordinator {
    private(set) var signOutCallCount = 0

    func openResult(_ result: QuizResult) {}
    func openSettings() {}
    func openEditProfile() {}
    func openAllAchievements() {}
    func openRegistration() {}

    func signOut() {
        signOutCallCount += 1
    }
}
