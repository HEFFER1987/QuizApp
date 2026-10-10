import Foundation
import Testing
@testable import QuizApp_iOS

@MainActor
struct GuestSessionTests {

    @Test func guestStatePersistence() throws {
        let defaults = UserDefaults(suiteName: "GuestSessionTests")!
        defaults.removePersistentDomain(forName: "GuestSessionTests")
        let manager = AppStateManager(userDefaults: defaults)

        manager.setGuest()
        #expect(manager.isGuest)
        #expect(manager.canAccessMainApp)
        #expect(!manager.canAuthorQuizzes)
        #expect(!manager.canPublishContent)

        let reloaded = AppStateManager(userDefaults: defaults)
        #expect(reloaded.isGuest)
    }

    @Test func authorizedReplacesGuest() {
        let defaults = UserDefaults(suiteName: "GuestSessionTests.auth")!
        defaults.removePersistentDomain(forName: "GuestSessionTests.auth")
        let manager = AppStateManager(userDefaults: defaults)

        manager.setGuest()
        manager.setAuthorized(userId: "user-1", provider: .email)

        #expect(manager.isRegisteredUser)
        #expect(!manager.isGuest)
        #expect(manager.canAuthorQuizzes)
        #expect(manager.canPublishContent)
    }

    @Test func guestProgressStoreAppendsAndSummarizes() {
        let defaults = UserDefaults(suiteName: "GuestSessionTests.progress")!
        defaults.removePersistentDomain(forName: "GuestSessionTests.progress")
        let store = GuestProgressStore(userDefaults: defaults)

        let result = QuizResult(
            id: "1",
            quizTitle: "Swift",
            iconName: "star",
            iconGlow: .blue,
            completedAt: Date(),
            correctCount: 8,
            totalCount: 10,
            durationSeconds: 120,
            xpEarned: 50,
            scorePercent: 80,
            isComposite: false
        )
        store.append(result)

        #expect(store.fetchResults().count == 1)
        let summary = store.fetchSummary()
        #expect(summary.totalAttempts == 1)
        #expect(summary.averageScorePercent == 80)
    }
}
