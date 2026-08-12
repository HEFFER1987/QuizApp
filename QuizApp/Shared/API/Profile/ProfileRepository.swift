import Foundation

enum ProfileRepositoryError: Error {
    case loadFailed
}

protocol ProfileRepository {
    func fetchProfile() async throws -> UserProfile
}

struct ProfileRepositoryMock: ProfileRepository {
    func fetchProfile() async throws -> UserProfile {
        Self.sampleProfile
    }

    private static let sampleProfile = UserProfile(
        displayName: "Roman",
        handle: "@romandev",
        titleBadge: "Swift Architect",
        avatarSystemName: "person.fill",
        level: 18,
        currentXP: 3450,
        levelXP: 5000,
        streakDays: 12,
        coins: 1250,
        achievementsUnlocked: 17,
        achievementsTotal: 32,
        achievements: [
            ProfileAchievement(
                id: "1",
                title: "Swift Master",
                iconName: "chevron.left.forwardslash.chevron.right",
                iconText: nil,
                glow: .orange,
                isLocked: false
            ),
            ProfileAchievement(
                id: "2",
                title: "100 Quizzes",
                iconName: nil,
                iconText: "100",
                glow: .blue,
                isLocked: false
            ),
            ProfileAchievement(
                id: "3",
                title: "Night Owl",
                iconName: "moon.stars.fill",
                iconText: nil,
                glow: .orange,
                isLocked: false
            ),
            ProfileAchievement(
                id: "4",
                title: "Speed",
                iconName: "bolt.fill",
                iconText: nil,
                glow: .blue,
                isLocked: false
            ),
            ProfileAchievement(
                id: "5",
                title: "iOS Expert",
                iconName: "lock.fill",
                iconText: nil,
                glow: .blue,
                isLocked: true
            )
        ],
        statistics: ProfileStatistics(
            quizzesCompleted: 48,
            quizzesCompletedMonthlyDelta: 8,
            accuracyPercent: 84,
            accuracyMonthlyDelta: 6,
            quizzesCreated: 12,
            quizzesCreatedMonthlyDelta: 2,
            globalRank: 14,
            topPercent: 1
        ),
        favorites: [
            Quiz(
                id: "fav-1",
                title: "Swift Basics",
                subtitle: nil,
                questionCount: 12,
                status: .published,
                iconName: "chevron.left.forwardslash.chevron.right",
                updatedAt: nil,
                attemptCount: 18,
                averageScorePercent: 67
            ),
            Quiz(
                id: "fav-2",
                title: "World History",
                subtitle: nil,
                questionCount: 20,
                status: .published,
                iconName: "globe.americas.fill",
                updatedAt: nil,
                attemptCount: 24,
                averageScorePercent: 82
            )
        ]
    )
}
