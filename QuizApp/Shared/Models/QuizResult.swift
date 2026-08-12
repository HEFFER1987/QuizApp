import Foundation

enum ResultsFilter: CaseIterable, Equatable, Hashable {
    case all
    case excellent
    case needsReview
    case composite
}

enum ResultIconGlow: String, Equatable {
    case blue
    case orange
    case purple
    case green
}

struct QuizResult: Identifiable, Equatable {
    let id: String
    let quizTitle: String
    let iconName: String
    let iconGlow: ResultIconGlow
    let completedAt: Date
    let correctCount: Int
    let totalCount: Int
    let durationSeconds: Int
    let xpEarned: Int
    let scorePercent: Int
    let isComposite: Bool
}

struct ResultsSummary: Equatable {
    let averageScorePercent: Int
    let quizzesCompleted: Int
    let totalAttempts: Int
    let streakDays: Int
}

extension QuizResult {
    var matchesExcellentFilter: Bool {
        scorePercent >= 90
    }

    var matchesNeedsReviewFilter: Bool {
        scorePercent < 70
    }

    var matchesCompositeFilter: Bool {
        isComposite
    }

    func matches(_ filter: ResultsFilter) -> Bool {
        switch filter {
        case .all:
            return true
        case .excellent:
            return matchesExcellentFilter
        case .needsReview:
            return matchesNeedsReviewFilter
        case .composite:
            return matchesCompositeFilter
        }
    }
}
