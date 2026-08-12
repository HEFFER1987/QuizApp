import Foundation

enum ProfileContentTab: CaseIterable, Equatable, Hashable {
    case myQuizzes
    case favorites
    case history
}

enum ProfileQuizStatusFilter: CaseIterable, Equatable, Hashable {
    case drafts
    case published
}

enum ProfileAchievementGlow: String, Equatable {
    case blue
    case orange
    case purple
    case green
}

struct ProfileAchievement: Identifiable, Equatable {
    let id: String
    let title: String
    let iconName: String?
    let iconText: String?
    let glow: ProfileAchievementGlow
    let isLocked: Bool
}

struct ProfileStatistics: Equatable {
    let quizzesCompleted: Int
    let quizzesCompletedMonthlyDelta: Int
    let accuracyPercent: Int
    let accuracyMonthlyDelta: Int
    let quizzesCreated: Int
    let quizzesCreatedMonthlyDelta: Int
    let globalRank: Int
    let topPercent: Int
}

struct UserProfile: Equatable {
    let displayName: String
    let handle: String
    let titleBadge: String
    let avatarSystemName: String
    let level: Int
    let currentXP: Int
    let levelXP: Int
    let streakDays: Int
    let coins: Int
    let achievementsUnlocked: Int
    let achievementsTotal: Int
    let achievements: [ProfileAchievement]
    let statistics: ProfileStatistics
    let favorites: [Quiz]
}

extension UserProfile {
    var xpRemaining: Int {
        max(levelXP - currentXP, 0)
    }

    var xpProgress: Double {
        guard levelXP > 0 else { return 0 }
        return min(Double(currentXP) / Double(levelXP), 1)
    }
}

extension ProfileAchievementGlow {
    var resultIconGlow: ResultIconGlow {
        switch self {
        case .blue: return .blue
        case .orange: return .orange
        case .purple: return .purple
        case .green: return .green
        }
    }
}
